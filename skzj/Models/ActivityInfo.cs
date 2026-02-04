namespace skzj.Models;

public sealed class ActivityInfo
{
    public string ActId { get; set; } = string.Empty;
    public string ActTitle { get; set; } = string.Empty;

    public string DisplayText => $"{ActTitle} (ID: {ActId})";

    public override string ToString()
    {
        return DisplayText;
    }
}
