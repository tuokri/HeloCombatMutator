class SystemTimeProvider extends Object;

struct DateTime
{
    var int Year;
    var int Month;
    var int DayOfWeek;
    var int Day;
    var int Hour;
    var int Min;
    var int Sec;
    var int MSec;
};

function GetSystemDateTime(out DateTime out_DT)
{
    local int Year;
    local int Month;
    local int DayOfWeek;
    local int Day;
    local int Hour;
    local int Min;
    local int Sec;
    local int MSec;

    GetSystemTime(Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec);

    out_DT.Year = Year;
    out_DT.Month = Month;
    out_DT.DayOfWeek = DayOfWeek;
    out_DT.Day = Day;
    out_DT.Hour = Hour;
    out_DT.Min = Min;
    out_DT.Sec = Sec;
    out_DT.MSec = MSec;
}
