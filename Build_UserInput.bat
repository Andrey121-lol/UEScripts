@echo off
cd /d %~dp0
setlocal EnableDelayedExpansion

set "ConfigFile=%~dp0UEPath.txt"
set "LogFile=%~dp0BuildLog.txt"

if exist "%ConfigFile%" (
    set /p UEPath=<"%ConfigFile%"
    if not exist "!UEPath!\Engine\Build\BatchFiles\RunUAT.bat" (
        echo ERROR: RunUAT.bat not found in "!UEPath!\Engine\Build\BatchFiles\". >> "%LogFile%"
        goto :SelectUEPath
    ) else (
        echo Using saved Unreal Engine path: "!UEPath!"
        goto :AskForPathChange
    )
) else (
    goto :SelectUEPath
)

:AskForPathChange
cls
echo === Unreal Engine Path ===
echo 0 = Keep current path: !UEPath!
echo 1 = Select new path
set /p ChangePath="Enter choice (0-1): "
if "!ChangePath!"=="1" goto :SelectUEPath
goto :SelectBuildConfig

:SelectUEPath
cls
echo ===========================================
echo Select your Unreal Engine folder.
echo ===========================================
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if ($f.ShowDialog() -eq 'OK') { $f.SelectedPath | Out-File '%ConfigFile%' -Encoding ASCII }}"
set /p UEPath=<"%ConfigFile%"
if not defined UEPath (
    echo No path selected. Exiting.
    pause
    exit /b
)
if not exist "%UEPath%\Engine\Build\BatchFiles\RunUAT.bat" (
    echo ERROR: RunUAT.bat not found at "%UEPath%\Engine\Build\BatchFiles\"! >> "%LogFile%"
    echo ERROR: RunUAT.bat not found! Check your Unreal Engine path.
    pause
    exit /b
)
echo New Unreal Engine path set: !UEPath!
goto :SelectBuildConfig

:SelectBuildConfig
cls
echo === Select Build Configuration ===
echo 0 = DebugGame
echo 1 = Development
echo 2 = Shipping
echo 3 = Shipping Distribution
echo 4 = Test
set /p BuildConfig="Enter choice (0-4): "
if "%BuildConfig%"=="0" (
    set "BuildConfiguration=DebugGame"
) else if "%BuildConfig%"=="1" (
    set "BuildConfiguration=Development"
) else if "%BuildConfig%"=="2" (
    set "BuildConfiguration=Shipping"
) else if "%BuildConfig%"=="3" (
    set "BuildConfiguration=Shipping"
    set "IsDistribution=-distribution"
) else if "%BuildConfig%"=="4" (
    set "BuildConfiguration=Test"
) else (
    echo Invalid choice, defaulting to Development.
    set "BuildConfiguration=Development"
)

:SelectCookingType
cls
echo === Select Cooking Type ===
echo 0 = Full (Full Rebuild)
echo 1 = Incremental (Only changed assets)
set /p CookType="Enter choice (0-1): "
if "%CookType%"=="0" (
    set "CookingType=-cook"
) else if "%CookType%"=="1" (
    set "CookingType=-cook -iterativecooking"
) else (
    echo Invalid choice, defaulting to Full Cook.
    set "CookingType=-cook"
)

for %%f in ("%~dp0*.uproject") do set "ProjectFile=%%~nxf"
if not defined ProjectFile (
    echo ERROR: No .uproject file found in script directory! >> "%LogFile%"
    echo ERROR: No .uproject file found! Check script location.
    pause
    exit /b
)

set "BuildPath=%~dp0..\Builds\Rev_Win64_%BuildConfiguration%"
for /f "tokens=2-4 delims=/." %%a in ('date /t') do set mydate=%%c-%%a-%%b
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do set mytime=%%a-%%b
set "BuildPath=%BuildPath%_%mydate%_%mytime%"

cls
echo ===========================================
echo Unreal Engine Path: !UEPath!
echo RunUAT.bat Path: !UEPath!\Engine\Build\BatchFiles\RunUAT.bat
echo Project File: %~dp0%ProjectFile%
echo Build Configuration: %BuildConfiguration%
echo Cooking Type: %CookingType%
echo Build Output Path: %BuildPath%
echo ===========================================
CALL "!UEPath!\Engine\Build\BatchFiles\RunUAT.bat" ^
    -ScriptsForProject="%~dp0%ProjectFile%" ^
    BuildCookRun ^
    -project="%~dp0%ProjectFile%" ^
    -noP4 ^
    -platform=Win64 ^
    -clientconfig=%BuildConfiguration% ^
    -serverconfig=%BuildConfiguration% ^
    -targetplatform=Win64 ^
    -build ^
    -archive -archivedirectory="%BuildPath%" ^
    %CookingType% ^
    -stage ^
    -pak ^
    -prereqs ^
    -package ^
    -compressed ^
    -utf8output
if %ERRORLEVEL% NEQ 0 (
    echo Build failed with code %ERRORLEVEL%. Check BuildLog.txt if needed.
    pause
    exit /b
)
for %%I in ("%BuildPath%") do set "FullBuildPath=%%~fI"
if not exist "!FullBuildPath!" (
    echo ERROR: Build path not found - !FullBuildPath! >> "%LogFile%"
    echo ERROR: Build path not found! Check logs.
    pause
    exit /b
)
explorer "!FullBuildPath!"
echo Build completed. Folder opened: !FullBuildPath!
pause
endlocal
exit /b
