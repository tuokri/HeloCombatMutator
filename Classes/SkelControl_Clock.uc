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
    InitDT = DT;
    bInitDone = True;
}

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
