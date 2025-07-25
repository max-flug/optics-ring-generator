# Optics Ring Generator - Windows Installer Script
# This creates a single-file installer for Windows

!include "MUI2.nsh"
!include "FileFunc.nsh"

# Define application information
!define APP_NAME "Optics Ring Generator"
!define APP_VERSION "0.1.0"
!define APP_PUBLISHER "Optics Ring Generator Team"
!define APP_URL "https://github.com/your-repo/optics-ring-generator"
!define APP_DESCRIPTION "Generate 3D printable precision optics support rings"

# Define installer file name
!define INSTALLER_NAME "OpticsRingGenerator-${APP_VERSION}-Setup.exe"

# Set basic installer properties
Name "${APP_NAME}"
OutFile "dist\${INSTALLER_NAME}"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKCU "Software\${APP_NAME}" ""
RequestExecutionLevel admin

# Interface Configuration
!define MUI_ABORTWARNING
!define MUI_ICON "installer\icon.ico"
!define MUI_UNICON "installer\icon.ico"

# Welcome page
!insertmacro MUI_PAGE_WELCOME

# License page (optional)
# !define MUI_LICENSEPAGE_TEXT_TOP "Please review the license terms below."
# !insertmacro MUI_PAGE_LICENSE "LICENSE"

# Components page
!insertmacro MUI_PAGE_COMPONENTS

# Directory page
!insertmacro MUI_PAGE_DIRECTORY

# Installation page
!insertmacro MUI_PAGE_INSTFILES

# Finish page
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN "$INSTDIR\OpticsRingGenerator.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch ${APP_NAME}"
!define MUI_FINISHPAGE_LINK "Visit our website"
!define MUI_FINISHPAGE_LINK_LOCATION "${APP_URL}"
!insertmacro MUI_PAGE_FINISH

# Uninstaller pages
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

# Languages
!insertmacro MUI_LANGUAGE "English"

# Version Information
VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "ProductVersion" "${APP_VERSION}"
VIAddVersionKey "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey "FileDescription" "${APP_DESCRIPTION}"
VIAddVersionKey "FileVersion" "${APP_VERSION}"

# Main installation section
Section "!${APP_NAME} Core" SecCore
    SectionIn RO  # Required section
    
    SetOutPath "$INSTDIR"
    
    # Copy main executable
    File "target\release\optics-ring-generator.exe"
    
    # Create launcher executable
    File "dist\OpticsRingGenerator.exe"
    
    # Copy documentation
    File "README.md"
    File "DISTRIBUTION.md"
    
    # Create shortcuts
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\OpticsRingGenerator.exe"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\OpticsRingGenerator.exe"
    
    # Write registry information
    WriteRegStr HKCU "Software\${APP_NAME}" "" "$INSTDIR"
    WriteRegStr HKCU "Software\${APP_NAME}" "Version" "${APP_VERSION}"
    
    # Write uninstall information
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\OpticsRingGenerator.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${APP_PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1
    
    # Calculate and write install size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "EstimatedSize" "$0"
    
    # Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
SectionEnd

# Optional components
Section "Add to PATH" SecPath
    # Add installation directory to PATH
    EnVar::SetHKLM
    EnVar::AddValue "PATH" "$INSTDIR"
    Pop $0
    DetailPrint "Added to PATH: $0"
SectionEnd

Section "File Association" SecAssoc
    # Associate .ring files with the application (optional)
    WriteRegStr HKCR ".ring" "" "OpticsRingFile"
    WriteRegStr HKCR "OpticsRingFile" "" "Optics Ring Configuration"
    WriteRegStr HKCR "OpticsRingFile\shell\open\command" "" '"$INSTDIR\OpticsRingGenerator.exe" "%1"'
    WriteRegStr HKCR "OpticsRingFile\DefaultIcon" "" "$INSTDIR\OpticsRingGenerator.exe,0"
SectionEnd

# Component descriptions
LangString DESC_SecCore ${LANG_ENGLISH} "Core ${APP_NAME} application files (required)"
LangString DESC_SecPath ${LANG_ENGLISH} "Add ${APP_NAME} to system PATH for command-line access"
LangString DESC_SecAssoc ${LANG_ENGLISH} "Associate .ring files with ${APP_NAME}"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_SecCore)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPath} $(DESC_SecPath)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecAssoc} $(DESC_SecAssoc)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

# Uninstaller section
Section "Uninstall"
    # Remove files
    Delete "$INSTDIR\optics-ring-generator.exe"
    Delete "$INSTDIR\OpticsRingGenerator.exe"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\DISTRIBUTION.md"
    Delete "$INSTDIR\Uninstall.exe"
    
    # Remove shortcuts
    Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk"
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir "$SMPROGRAMS\${APP_NAME}"
    
    # Remove registry entries
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKCU "Software\${APP_NAME}"
    
    # Remove file associations
    DeleteRegKey HKCR ".ring"
    DeleteRegKey HKCR "OpticsRingFile"
    
    # Remove from PATH
    EnVar::SetHKLM
    EnVar::DeleteValue "PATH" "$INSTDIR"
    
    # Remove installation directory
    RMDir "$INSTDIR"
    
SectionEnd
