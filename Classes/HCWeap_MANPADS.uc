/*
 * Copyright (c) 2021-2024 Tuomo Kriikkula <tuokri@tuta.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
class HCWeap_MANPADS extends ROWeap_RPG7_RocketLauncher;

// How distant a target we can lock onto.
var (HeatSeeker) float MaxTargetDistance;
// Trace box extent for checking locking candidate.
var (HeatSeeker) vector LockTraceExtent;
// Override the projectile's MaxAngleDelta. For debug purposes only.
var (HeatSeeker) float MaxAngleDeltaOverride;
// Minimum time to track target before locking.
var (HeatSeeker) float MinTrackTime;
// Which classes the weapon is able to lock onto.
var (HeatSeeker) array< class<Object> > TrackableActorClasses;

// TODO: lock target replication needs double-checking!

var float LastLockStartTime;
var Actor LastLockCandidate; // TODO: this can't be an actor?!
var Actor LastLockedTarget; // TODO: this can't be an actor?!

simulated state Active
{
    // TODO: This resets lock too early... Need to reset it on ADS or reload.
    simulated function BeginState(Name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        LastLockedTarget = None;
        LastLockCandidate = None;
    }

    simulated function bool AllowFiring(byte FireModeNum = 0)
    {
        if (LastLockedTarget != None)
        {
            return super.AllowFiring(FireModeNum);
        }
        else
        {
            return False;
        }
    }

    simulated event Tick(float DeltaTime)
    {
        Global.Tick(DeltaTime);

        if (bUsingSights && LastLockedTarget == None && WorldInfo.NetMode != NM_DedicatedServer)
        {
            TryLock();
        }
    }
}

simulated function LockTarget(Actor Target)
{
    // TODO: Buzzer and indicator light.
    if (PlayerController(Instigator.Controller) != None)
    {
        PlayerController(Instigator.Controller).ClientMessage("Locked Target = " $ Target);
    }

    // `hclog("LockTarget(): Target = " $ Target,, 'StrelaDebug');

    LastLockedTarget = Target;
    ServerLockTarget(Target);
}

// Set lock server side and validate client input.
reliable server function ServerLockTarget(Actor Target)
{
    local int i;

    `hcdebug("Target=" $ Target $ ", Target.Class.Name=" $ Target.Class.Name);

    for (i = 0; i < TrackableActorClasses.Length; ++i)
    {
        if (Target.IsA(TrackableActorClasses[i].Class.Name))
        {
            LastLockedTarget = Target;
            return;
        }
    }

    LastLockedTarget = None;
}

// TODO: remove duplicates.
simulated function TryLock()
{
    local Vehicle VehicleCandidate;
    local ROSupportAircraft AircraftCandidate;
    local vector HitLoc;
    local vector HitNorm;
    local vector End;
    local vector Start;

    Start = GetPhysicalFireStartLoc();
    // TODO: why adjusted aim vector????
    End = Start + GetAdjustedAimVector(Start, True) * MaxTargetDistance;

    // DrawDebugLine(Start, End, 255, 15, 15, False);

    // TODO: think about this logic!
    // TODO: when tracing actors, check if the actor has a heat source component!
    ForEach TraceActors(class'Vehicle', VehicleCandidate, HitLoc, HitNorm, End, Start, LockTraceExtent)
    {
        `hclog("TryLock(): VehicleCandidate = " $ VehicleCandidate,, 'StrelaDebug');

        // Skip myself.
        if (VehicleCandidate == GetTraceOwner()) // || (VehicleCandidate.IsInState('Dying'))
        {
            // `hclog("TryLock(): VehicleCandidate is trace owner ",, 'StrelaDebug');
            continue;
        }

        // Skip teammates in team games.
        // if (WorldInfo.Game.bTeamGame && (Instigator.GetTeamNum() == VehicleCandidate.GetTeamNum()))
        // {
        //     // `hclog("TryLock(): VehicleCandidate is teammate ",, 'StrelaDebug');
        //     continue;
        // }

        if (LastLockCandidate != VehicleCandidate)
        {
            LastLockCandidate = VehicleCandidate;
            LastLockStartTime = WorldInfo.TimeSeconds;
        }
        else if (LastLockStartTime + MinTrackTime > WorldInfo.TimeSeconds)
        {
            LockTarget(VehicleCandidate);
            break;
        }
    }

    if (LastLockedTarget != None)
    {
        return;
    }

    ForEach TraceActors(class'ROSupportAircraft', AircraftCandidate, HitLoc, HitNorm, End, Start, LockTraceExtent)
    {
        `hclog("TryLock(): AircraftCandidate = " $ AircraftCandidate,, 'StrelaDebug');

        // Skip myself.
        if (AircraftCandidate == GetTraceOwner()) // || (AircraftCandidate.IsInState('Dying'))
        {
            continue;
        }

        // Skip teammates in team games.
        // if (WorldInfo.Game.bTeamGame && (Instigator.GetTeamNum() == AircraftCandidate.GetTeamNum()))
        // {
        //     continue;
        // }

        if (LastLockCandidate != AircraftCandidate)
        {
            LastLockCandidate = AircraftCandidate;
            LastLockStartTime = WorldInfo.TimeSeconds;
        }
        else if (LastLockStartTime + MinTrackTime > WorldInfo.TimeSeconds)
        {
            LockTarget(AircraftCandidate);
            break;
        }
    }
}

simulated function Projectile ProjectileFire()
{
    local Projectile SpawnedProjectile;
    local HCHeatSeekingProjectile HeatSeeker;

    SpawnedProjectile = super.ProjectileFire();

    // `hclog("ProjectileFire(): Projectile = " $ SpawnedProjectile $ ", LastLockedTarget = " $ LastLockedTarget,, 'StrelaDebug');

    if (SpawnedProjectile != None && LastLockedTarget != None)
    {
        HeatSeeker = HCHeatSeekingProjectile(SpawnedProjectile);
        // `hclog("ProjectileFire(): HeatSeeker = " $ HeatSeeker,, 'StrelaDebug');

        if (HeatSeeker != None)
        {
            HeatSeeker.LockedTarget = LastLockedTarget;
            if (MaxAngleDeltaOverride > 0)
            {
                HeatSeeker.MaxAngleDelta = MaxAngleDeltaOverride;
            }
        }
    }

    // PlayerController(Instigator.Controller).SetViewTarget(SpawnedProjectile);

    return SpawnedProjectile;
}

DefaultProperties
{
    MaxTargetDistance=100000 // 2000m.
    LockTraceExtent=(X=50,Y=50,Z=50) // 2m * 2m * 2m extent box.
    MinTrackTime=5.0 // Seconds.

    // TODO: This shouldn't be here!
    TrackableActorClasses(0)=class'HCHeatSourceComponent'
}
