@echo off
REM Optics Ring Generator - Windows Launcher
REM This batch file launches the interactive UI mode

title Optics Ring Generator

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "BINARY_PATH=%SCRIPT_DIR%optics-ring-generator.exe"

REM Check if binary exists
if not exist "%BINARY_PATH%" (
    echo Error: optics-ring-generator.exe not found at %BINARY_PATH%
    echo Please build the project with 'cargo build --release' and copy the binary to this directory.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

REM Launch in UI mode
echo 🔬 Launching Optics Ring Generator UI...
echo Press Ctrl+C to exit
echo.

"%BINARY_PATH%" --ui

REM Keep window open if there's an error
if errorlevel 1 (
    echo.
    echo An error occurred. Press any key to exit...
    pause >nul
)
