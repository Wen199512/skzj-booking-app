namespace skzj.Models;

public sealed class LoginResult
{
    public LoginResult(bool ok, string msg, string? token)
    {
        Ok = ok;
        Msg = msg;
        Token = token;
    }

    public bool Ok { get; }
    public string Msg { get; }
    public string? Token { get; }
}
