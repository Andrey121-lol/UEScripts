@echo off

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

ECHO ---- BUILD CONFIGURATION ----
ECHO 0 = DebugGame
ECHO 1 = Development
ECHO 2 = Shipping
ECHO 3 = Shipping Distribution
ECHO 4 = Test
echo ============================

SET /P BuildConfiguration= Please enter an BuildConfiguration: 
IF "%BuildConfiguration%" == "" (
	ECHO BuildConfiguration=1
	set BuildConfiguration=1
) 

ECHO 0 = Clear Build
ECHO 1 = Iterative
echo ============================
SET /P Iterative= Clear or iterative cooking?: 
IF %Iterative% EQU 1  (
	ECHO Iterative build
	set IsIterative=-iterativecooking
) 

For /f "tokens=2-4 delims=/." %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a-%%b)
echo %mydate%_%mytime%

echo --- BUILD STARTED AT %date% %mytime% ---


IF %BuildConfiguration% EQU 0 (
	
	echo BUILDING DEBUG GAME

	set BuildConfiguration=DebugGame
	set CompressionLevel=Fast
) ELSE (

IF %BuildConfiguration% EQU 1 (

	echo BUILDING DEVELOPMENT
	
	set BuildConfiguration=Development
	set CompressionLevel=Fast
) ELSE (

IF %BuildConfiguration% EQU 2 (

	echo BUILDING SHIPPING
	
	set BuildConfiguration=Shipping
	set CompressionLevel=Optimal1
) ELSE (
IF %BuildConfiguration% EQU 3 (

	echo BUILDING SHIPPING
	
	set BuildConfiguration=Shipping
	set IsDistribution=-distribution
	set CompressionLevel=Optimal3
) ELSE (
IF %BuildConfiguration% EQU 4 (

	echo BUILDING Test
	
	set BuildConfiguration=Test
	set CompressionLevel=Optimal1
) ELSE (
	echo ERROR INPUT - BUILDING DEVELOPMENT
	
	set BuildConfiguration=Development
)))))

echo --- BUILD STARTED AT %date% %mytime% ---

CALL  S:\UnrealEngine\Engine\Build\BatchFiles\RunUAT.bat -ScriptsForProject="%~dp0ILS.uproject" BuildCookRun -project="%~dp0ILS.uproject" -platform=%PLATFORM% -configuration=%BuildConfiguration% -archive -archivedirectory="%~dp0../Builds/Rev_%PLATFORM%_%BuildConfiguration%/" -unattended -utf8output -build -cook -stage -pak -prereqs -package -createreleaseversion=1.0 -compressed %IsIterative% %IsDistribution% %UbtArgs%

echo F | xcopy "..\Engine\Programs\AutomationTool\Saved\Logs\Log.txt" ..\Builds\Rev_%date%_%mytime%\Log_%PLATFORM%_%date%_%mytime%.txt /Y /F
explorer ..\Builds\Rev_%date%_%mytime%\

pause
endlocal