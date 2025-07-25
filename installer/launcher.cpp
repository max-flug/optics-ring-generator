// Windows Launcher for Optics Ring Generator
// This creates a proper Windows executable that launches the UI

#include <windows.h>
#include <string>
#include <filesystem>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // Get the directory where this executable is located
    char exePath[MAX_PATH];
    GetModuleFileNameA(NULL, exePath, MAX_PATH);
    
    std::filesystem::path exeDir = std::filesystem::path(exePath).parent_path();
    std::filesystem::path binaryPath = exeDir / "optics-ring-generator.exe";
    
    // Check if the main binary exists
    if (!std::filesystem::exists(binaryPath)) {
        MessageBoxA(NULL, 
            "Error: optics-ring-generator.exe not found!\n\n"
            "Please ensure the application is properly installed.",
            "Optics Ring Generator", 
            MB_OK | MB_ICONERROR);
        return 1;
    }
    
    // Create command line to launch UI mode
    std::string cmdLine = "\"" + binaryPath.string() + "\" --ui";
    
    // Launch the application
    STARTUPINFOA si = {0};
    PROCESS_INFORMATION pi = {0};
    si.cb = sizeof(si);
    
    if (CreateProcessA(NULL, 
                      const_cast<char*>(cmdLine.c_str()),
                      NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
        // Close handles
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
        return 0;
    } else {
        MessageBoxA(NULL, 
            "Failed to launch Optics Ring Generator.\n\n"
            "Please try running as administrator or check your installation.",
            "Optics Ring Generator", 
            MB_OK | MB_ICONERROR);
        return 1;
    }
}
