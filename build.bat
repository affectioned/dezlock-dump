@echo off
setlocal

rem Find the newest Visual Studio with the C++ toolset and map it to a CMake generator.
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" set "VSWHERE=%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"

set "GENERATOR="
if exist "%VSWHERE%" (
    for /f "tokens=1 delims=." %%v in (
        '"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationVersion'
    ) do set "VSMAJOR=%%v"
)

if "%VSMAJOR%"=="18" set "GENERATOR=Visual Studio 18 2026"
if "%VSMAJOR%"=="17" set "GENERATOR=Visual Studio 17 2022"
if "%VSMAJOR%"=="16" set "GENERATOR=Visual Studio 16 2019"
if "%VSMAJOR%"=="15" set "GENERATOR=Visual Studio 15 2017"

if defined GENERATOR (
    echo Using generator: %GENERATOR%
    rem A cache from a different generator makes configure fail; drop it.
    if exist build\CMakeCache.txt (
        findstr /c:"CMAKE_GENERATOR:INTERNAL=%GENERATOR%" build\CMakeCache.txt >nul || rd /s /q build
    )
    cmake -B build -G "%GENERATOR%" -A x64 || exit /b 1
) else (
    echo No Visual Studio C++ install detected, falling back to CMake's default generator.
    cmake -B build -A x64 || exit /b 1
)

cmake --build build --config Release || exit /b 1
echo.
echo Build complete! Output in build\bin\Release\
