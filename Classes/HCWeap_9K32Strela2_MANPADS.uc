class HCWeap_9K32Strela2_MANPADS extends ROWeap_RPG7_RocketLauncher;

// How distant a target we can lock onto.
var (HeatSeeker) float MaxTargetDistance;
// Trace box extent for checking locking candidate.
var (HeatSeeker) vector LockTraceExtent;
// Override the projectile's MaxAngleDelta. For debug purposes only.
var (HeatSeeker) float MaxAngleDeltaOverride;

var ROVehicle LastLockedTarget;

simulated state Active
{
    simulated function BeginState(Name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        LastLockedTarget = None;
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

        if (bUsingSights && LastLockedTarget == None)
        {
            TryLock();
        }
    }
}

simulated function LockTarget(ROVehicle Target)
{
    // TODO: Buzzer and indicator light.
    if (PlayerController(Instigator.Controller) != None)
    {
        PlayerController(Instigator.Controller).ClientMessage("Locked Target = " $ Target);
    }

    // `log("LockTarget(): Target = " $ Target,, 'StrelaDebug');

    LastLockedTarget = Target;
    ServerLockTarget(Target);
}

reliable server function ServerLockTarget(ROVehicle Target)
{
    LastLockedTarget = Target;
}

// TODO: lock on timer.
simulated function TryLock()
{
    local ROVehicle Candidate;
    local vector HitLoc;
    local vector HitNorm;
    local vector End;
    local vector Start;

    Start = GetPhysicalFireStartLoc();
    End = Start + GetAdjustedAimVector(Start, True) * MaxTargetDistance;

    DrawDebugLine(Start, End, 255, 15, 15, False);

    ForEach TraceActors(class'ROVehicle', Candidate, HitLoc, HitNorm, End, Start, LockTraceExtent)
    {
        // `log("TryLock(): Candidate = " $ Candidate,, 'StrelaDebug');

        // Skip myself.
        if (Candidate == GetTraceOwner()) // || (Candidate.IsInState('Dying'))
        {
            // `log("TryLock(): Candidate is trace owner ",, 'StrelaDebug');
            continue;
        }

        // Skip teammates in team games.
        if (WorldInfo.Game.bTeamGame && (Instigator.GetTeamNum() == Candidate.GetTeamNum()))
        {
            // `log("TryLock(): Candidate is teammate ",, 'StrelaDebug');
            continue;
        }

        // Break on first good match.
        LockTarget(Candidate);
        break;
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
    MaxTargetDistance=25000 // 500m.
    LockTraceExtent=(X=50,Y=50,Z=50) // 2m * 2m * 2m extent box.

    WeaponContentClass(0)="HeloCombat.HCWeap_9K32Strela2_MANPADS_Content"
    WeaponProjectiles(0)=class'HCProjectile_Strela2'

    PreFireTraceLength=0
    MaxAngleDeltaOverride=0
}
