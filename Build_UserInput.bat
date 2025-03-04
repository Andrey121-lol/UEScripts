@echo off
setlocal enabledelayedexpansion

:: Prompt before selecting folder
echo =====================================================
echo  Please select the folder where Unreal Engine is installed.
echo  Example: S:\UnrealEngine or C:\Program Files\Epic Games\UE_5.x
echo =====================================================
pause

:: Folder selection using PowerShell
for /f "delims=" %%I in ('powershell -Command "(New-Object -ComObject Shell.Application).BrowseForFolder(0, 'Select Unreal Engine folder', 0x11).self.Path"') do set "UnrealPath=%%I"

:: Define full path to RunUAT.bat
set "RunUATPath=%UnrealPath%\Engine\Build\BatchFiles\RunUAT.bat"

:: Validate RunUAT.bat path
if not exist "%RunUATPath%" (
    echo =====================================================
    echo  ERROR: RunUAT.bat not found at:
    echo  "%RunUATPath%"
    echo  Please make sure the correct Unreal Engine folder is selected.
    echo =====================================================
    pause
    exit /b
)

echo Found RunUAT.bat: %RunUATPath%
pause

:: Find .uproject file in the current directory
set ProjectFile=
for /f "delims=" %%i in ('dir /b "%~dp0*.uproject"') do set ProjectFile=%%i

:: Check if .uproject file was found
if "%ProjectFile%"=="" (
    echo =====================================================
    echo  ERROR: No .uproject file found in the current directory!
    echo =====================================================
    pause
    exit /b
)

:: Extract project name
for %%i in ("%ProjectFile%") do set ProjectName=%%~ni

echo Found project: %ProjectName%
echo Full path: %~dp0%ProjectFile%
pause

set BuildConfiguration=1
set CompressionLevel="Fast"
set IsClient=0
set IsDistribution=
set Iterative=0
set IsIterative=
set PLATFORM=Win64
set ANDROID_ADDITIONALS=
set INPUTCookFlavor=
set COOKFLAVOR=Multi
set both=0
set UbtArgs=
set CmdLineArgs=

:: Select build configuration
ECHO ---- BUILD CONFIGURATION ----
ECHO 0 = DebugGame
ECHO 1 = Development
ECHO 2 = Shipping
ECHO 3 = Shipping Distribution
ECHO 4 = Test
echo ============================

SET /P BuildConfiguration= "Enter Build Configuration (default = 1): " 
IF "%BuildConfiguration%"=="" (
    echo No input, setting BuildConfiguration=1
    set BuildConfiguration=1
) 

:: Select cooking method
ECHO 0 = Clear Build
ECHO 1 = Iterative
echo ============================

SET /P Iterative= "Clear or iterative cooking? (0/1, default = 0): " 
IF "%Iterative%"=="" (
    echo No input, setting Iterative=0
    set Iterative=0
)

echo DEBUG: Iterative = %Iterative%
pause

IF "%Iterative%"=="1" (
    ECHO Iterative build selected
    set IsIterative=-iterativecooking
) ELSE (
    ECHO Clear build selected
)

:: Generate date and time
For /f "tokens=2-4 delims=/." %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a-%%b)
echo %mydate%_%mytime%

echo --- BUILD STARTED AT %date% %mytime% ---

:: Process build configuration selection
IF "%BuildConfiguration%"=="0" (
    echo BUILDING DEBUG GAME
    set BuildConfiguration=DebugGame
    set CompressionLevel=Fast
) ELSE IF "%BuildConfiguration%"=="1" (
    echo BUILDING DEVELOPMENT
    set BuildConfiguration=Development
    set CompressionLevel=Fast
) ELSE IF "%BuildConfiguration%"=="2" (
    echo BUILDING SHIPPING
    set BuildConfiguration=Shipping
    set CompressionLevel=Optimal1
) ELSE IF "%BuildConfiguration%"=="3" (
    echo BUILDING SHIPPING DISTRIBUTION
    set BuildConfiguration=Shipping
    set IsDistribution=-distribution
    set CompressionLevel=Optimal3
) ELSE IF "%BuildConfiguration%"=="4" (
    echo BUILDING TEST
    set BuildConfiguration=Test
    set CompressionLevel=Optimal1
) ELSE (
    echo ERROR INPUT - BUILDING DEVELOPMENT
    set BuildConfiguration=Development
)

echo --- BUILD STARTED AT %date% %mytime% ---

:: Run the build process
CALL "%RunUATPath%" -ScriptsForProject="%~dp0%ProjectFile%" BuildCookRun -project="%~dp0%ProjectFile%" -platform=%PLATFORM% -configuration=%BuildConfiguration% -archive -archivedirectory="%~dp0../Builds/Rev_%PLATFORM%_%BuildConfiguration%/" -unattended -utf8output -build -cook -stage -pak -prereqs -package -createreleaseversion=1.0 -compressed %IsIterative% %IsDistribution% %UbtArgs%

:: Copy logs
echo F | xcopy "..\Engine\Programs\AutomationTool\Saved\Logs\Log.txt" "..\Builds\Rev_%date%_%mytime%\Log_%PLATFORM%_%date%_%mytime%.txt" /Y /F

:: Open build directory
explorer ..\Builds\Rev_%date%_%mytime%\

pause
endlocal
