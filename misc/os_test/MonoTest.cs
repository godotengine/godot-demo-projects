using Godot;
using System;

public class MonoTest : Node
{
    public string Architecture()
    {
#if GODOT_ARM64 || GODOT_ARM64_V8A
        return "64-bit ARM";
#elif GODOT_ARMV7 || GODOT_ARMEABI_V7A
        return "32-bit ARM";
#elif GODOT_X86_64
        return "64-bit x86";
#elif GODOT_X86
        return "32-bit x86";
#elif GODOT_128
        return "128-bit";
#elif GODOT_64
        return "64-bit";
#elif GODOT_32
        return "32-bit";
#else
        return "Unknown";
#endif
    }

    public string OperatingSystem()
    {
#if GODOT_WINDOWS
        return "Windows";
#elif GODOT_LINUXBSD || GODOT_X11
        return "Linux (or BSD)";
#elif GODOT_SERVER
        return "Server (Linux or BSD)";
#elif GODOT_MACOS || GODOT_OSX
        return "macOS";
#elif GODOT_ANDROID
        return "Android";
#elif GODOT_IOS
        return "iOS";
#elif GODOT_HTML5
        return "HTML5";
#elif GODOT_HAIKU
        return "Haiku";
#elif GODOT_UWP
        return "UWP (Windows 10)";
#else
        return "Unknown";
#endif
    }

    public string PlatformType()
    {
#if GODOT_PC
        return "PC";
#elif GODOT_MOBILE
        return "Mobile";
#elif GODOT_WEB
        return "Web";
#elif GODOT
        return "Godot Editor (not exported)";
#else
        return "Unknown";
#endif
    }

    public string TextureCompression()
    {
        string compression = "";
#if GODOT_S3TC
        compression += "S3TC";
#endif
#if GODOT_ETC
        if (compression.Length > 0)
        {
            compression += ", ";
        }
        compression += "ETC";
#endif
#if GODOT_ETC2
        if (compression.Length > 0)
        {
            compression += ", ";
        }
        compression += "ETC2";
#endif
        if (compression.Length > 0)
        {
            return compression;
        }
        return "Not exported or no textures";
    }
}
