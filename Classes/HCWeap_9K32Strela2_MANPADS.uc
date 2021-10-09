class HCWeap_9K32Strela2_MANPADS extends ROWeap_RPG7_RocketLauncher;

// How distant a target we can lock onto.
var (HeatSeeker) float MaxTargetDistance;
// Trace box extent for checking locking candidate.
var (HeatSeeker) vector LockTraceExtent;
// Override the projectile's MaxAngleDelta. For debug purposes only.
var (HeatSeeker) float MaxAngleDeltaOverride;
// Minimum time to track targer before locking.
var (HeatSeeker) float MinTrackTime;

var float LastLockStartTime;
var Actor LastLockCandidate;
var Actor LastLockedTarget;

simulated state Active
{
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

    `log("LockTarget(): Target = " $ Target,, 'StrelaDebug');

    LastLockedTarget = Target;
    ServerLockTarget(Target);
}

reliable server function ServerLockTarget(Actor Target)
{
    LastLockedTarget = Target;
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
    End = Start + GetAdjustedAimVector(Start, True) * MaxTargetDistance;

    DrawDebugLine(Start, End, 255, 15, 15, False);

    ForEach TraceActors(class'Vehicle', VehicleCandidate, HitLoc, HitNorm, End, Start, LockTraceExtent)
    {
        `log("TryLock(): VehicleCandidate = " $ VehicleCandidate,, 'StrelaDebug');

        // Skip myself.
        if (VehicleCandidate == GetTraceOwner()) // || (VehicleCandidate.IsInState('Dying'))
        {
            // `log("TryLock(): VehicleCandidate is trace owner ",, 'StrelaDebug');
            continue;
        }

        // Skip teammates in team games.
        if (WorldInfo.Game.bTeamGame && (Instigator.GetTeamNum() == VehicleCandidate.GetTeamNum()))
        {
            // `log("TryLock(): VehicleCandidate is teammate ",, 'StrelaDebug');
            continue;
        }

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
        `log("TryLock(): AircraftCandidate = " $ AircraftCandidate,, 'StrelaDebug');

        // Skip myself.
        if (AircraftCandidate == GetTraceOwner()) // || (AircraftCandidate.IsInState('Dying'))
        {
            continue;
        }

        // Skip teammates in team games.
        if (WorldInfo.Game.bTeamGame && (Instigator.GetTeamNum() == AircraftCandidate.GetTeamNum()))
        {
            continue;
        }

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

    // `log("ProjectileFire(): Projectile = " $ SpawnedProjectile $ ", LastLockedTarget = " $ LastLockedTarget,, 'StrelaDebug');

    if (SpawnedProjectile != None && LastLockedTarget != None)
    {
        HeatSeeker = HCHeatSeekingProjectile(SpawnedProjectile);
        // `log("ProjectileFire(): HeatSeeker = " $ HeatSeeker,, 'StrelaDebug');

        if (HeatSeeker != None)
        {
            HeatSeeker.LockedTarget = LastLockedTarget;
            if (MaxAngleDeltaOverride > 0)
            {
                HeatSeeker.MaxAngleDelta = MaxAngleDeltaOverride;
            }
        }
    }

    return SpawnedProjectile;
}

DefaultProperties
{
    MaxTargetDistance=100000 // 2000m.
    LockTraceExtent=(X=50,Y=50,Z=50) // 2m * 2m * 2m extent box.
    MinTrackTime=2.0

    WeaponContentClass(0)="HeloCombat.HCWeap_9K32Strela2_MANPADS_Content"
    WeaponProjectiles(0)=class'HCProjectile_Strela2'

    PreFireTraceLength=0
    MaxAngleDeltaOverride=0
}
