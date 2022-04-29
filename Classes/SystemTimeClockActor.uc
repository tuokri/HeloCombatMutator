class SystemTimeClockActor extends Actor
    dependson(SystemTimeProvider)
    placeable;

var name SecondsControlName;
var name MinutesControlName;
var name HoursControlName;

var SkelControl_Clock SK_Seconds;
var SkelControl_Clock SK_Minutes;
var SkelControl_Clock SK_Hours;

var SkeletalMeshComponent ClockMesh;

// TODO: probably better to have 1 global singleton STP per player (in PlayerController).
var SystemTimeProvider STP;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    local SkelControl_Clock TempSK;
    local DateTime DT;

    super.PostInitAnimTree(SkelComp);

    if (STP == None)
    {
        STP = new (self) class'SystemTimeProvider';
    }
    STP.GetSystemDateTime(DT);

    if (SecondsControlName != '')
    {
        TempSK = SkelControl_Clock(ClockMesh.FindSkelControl(SecondsControlName));
        if (TempSK != None)
        {
            SK_Seconds = TempSK;
            SK_Seconds.InitializeDateTime(DT);
        }
    }

    if (MinutesControlName != '')
    {
        TempSK = SkelControl_Clock(ClockMesh.FindSkelControl(MinutesControlName));
        if (TempSK != None)
        {
            SK_Minutes = TempSK;
            SK_Minutes.InitializeDateTime(DT);
        }
    }

    if (HoursControlName != '')
    {
        TempSK = SkelControl_Clock(ClockMesh.FindSkelControl(HoursControlName));
        if (TempSK != None)
        {
            SK_Hours = TempSK;
            SK_Hours.InitializeDateTime(DT);
        }
    }
}

DefaultProperties
{
    SecondsControlName=Clock_Seconds
    MinutesControlName=Clock_Minutes
    HoursControlName=Clock_Hours

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=true
    End Object
    Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=ClockMeshComp
        SkeletalMesh=SkeletalMesh'ClockTest.Mesh.RiggedClock'
        AnimTreeTemplate=AnimTree'ClockTest.Anim.AT_RiggedClock'
        LightEnvironment=MyLightEnvironment
    End Object
    CollisionComponent=ClockMeshComp
    ClockMesh=ClockMeshComp
    Components.Add(ClockMeshComp)
}
