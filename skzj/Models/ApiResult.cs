namespace skzj.Models;

public sealed class ApiResult
{
    public ApiResult(bool ok, string msg)
    {
        Ok = ok;
        Msg = msg;
    }

    public bool Ok { get; }
    public string Msg { get; }
}
