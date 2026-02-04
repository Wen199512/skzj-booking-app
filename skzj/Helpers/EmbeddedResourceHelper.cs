using System.Reflection;

namespace skzj.Helpers;

/// <summary>
/// 嵌入式资源助手类
/// </summary>
public static class EmbeddedResourceHelper
{
    /// <summary>
    /// 从嵌入式资源中提取文件到应用数据目录
    /// </summary>
    /// <param name="resourceName">资源名称（例如: "zh.txt"）</param>
    /// <returns>提取后的文件路径</returns>
    public static async Task<string> ExtractEmbeddedResourceAsync(string resourceName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        var fullResourceName = $"skzj.{resourceName}";
        
        // 目标路径：应用数据目录
        var targetPath = Path.Combine(FileSystem.AppDataDirectory, resourceName);
        
        // 如果文件已存在，直接返回（除非版本更新）
        if (File.Exists(targetPath))
        {
            return targetPath;
        }
        
        // 从嵌入式资源读取
        using var stream = assembly.GetManifestResourceStream(fullResourceName);
        if (stream == null)
        {
            throw new FileNotFoundException($"嵌入式资源 '{fullResourceName}' 未找到");
        }
        
        // 确保目录存在
        var directory = Path.GetDirectoryName(targetPath);
        if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }
        
        // 写入到应用数据目录
        using var fileStream = File.Create(targetPath);
        await stream.CopyToAsync(fileStream);
        
        return targetPath;
    }
    
    /// <summary>
    /// 检查嵌入式资源是否存在
    /// </summary>
    public static bool ResourceExists(string resourceName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        var fullResourceName = $"skzj.{resourceName}";
        return assembly.GetManifestResourceStream(fullResourceName) != null;
    }
    
    /// <summary>
    /// 列出所有嵌入式资源（调试用）
    /// </summary>
    public static string[] GetAllResourceNames()
    {
        var assembly = Assembly.GetExecutingAssembly();
        return assembly.GetManifestResourceNames();
    }
}
