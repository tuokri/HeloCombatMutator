// TODO: add support for choosing between sweeping/ticking second hand movement.
class SkelControl_Clock extends SkelControlSingleBone
    dependson(SystemTimeProvider);

const STEP_60 = 1092.2666666666666666666666666667;
const STEP_12 = 5461.3333333333333333333333333333;

enum EClockHandType
{
    ECHT_Seconds,
    ECHT_Minutes,
    ECHT_Hours,
};

var() EClockHandType ClockHandType;

var DateTime InitDT;
var bool bInitDone;

function InitializeDateTime(const out DateTime DT)
{
    local float AdjustedMinAsSecs;
    local float AdjustedHourAsSecs;

    InitDT = DT;

    switch (ClockHandType)
    {
        case ECHT_Seconds:
            HandleSeconds(InitDT.Sec + (InitDT.MSec * 1000));
            break;
        case ECHT_Minutes:
            AdjustedMinAsSecs = float(InitDT.Min) * 60.0;
            AdjustedMinAsSecs += InitDT.Sec;
            AdjustedMinAsSecs += (InitDT.MSec * 1000);
            HandleMinutes(AdjustedMinAsSecs);
            break;
        case ECHT_Hours:
            if (InitDT.Hour > 12)
            {
                AdjustedHourAsSecs = InitDT.Hour - 12.0;
            }
            else
            {
                AdjustedHourAsSecs = float(InitDT.Hour);
            }
            AdjustedHourAsSecs += (InitDT.Min / 60.0);
            AdjustedHourAsSecs += (InitDT.MSec * 1000);
            AdjustedHourAsSecs *= 3600;
            HandleHours(AdjustedHourAsSecs);
            break;
    }

    bInitDone = True;
}

// TODO: Should probably combine all hands into a single controller to have fewer script ticking objects?
event TickSkelControl(float DeltaTime, SkeletalMeshComponent SkelComp)
{
    super.TickSkelControl(DeltaTime, SkelComp);

    if (!bInitDone)
    {
        return;
    }

    switch (ClockHandType)
    {
        case ECHT_Seconds:
            HandleSeconds(DeltaTime);
            break;
        case ECHT_Minutes:
            HandleMinutes(DeltaTime);
            break;
        case ECHT_Hours:
            HandleHours(DeltaTime);
            break;
    }
}

function HandleSeconds(float DeltaTime)
{
    BoneRotation.Yaw += DeltaTime * STEP_60;
    // `log("SecondsRot = " $ BoneRotation.Yaw);
}

function HandleMinutes(float DeltaTime)
{
    BoneRotation.Yaw += (DeltaTime / 60) * STEP_60;
    // `log("MinutesRot = " $ BoneRotation.Yaw);
}

function HandleHours(float DeltaTime)
{
    BoneRotation.Yaw += (DeltaTime / 3600) * STEP_12;
}

DefaultProperties
{
    bShouldTickInScript=True
    bInitDone=False
}
