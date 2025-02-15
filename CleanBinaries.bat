@echo off

rem Define the paths to the project root and plugins directory
set PROJECT_ROOT=%~dp0
set PLUGINS_DIR=%PROJECT_ROOT%Plugins
set FEATURES_DIR=%PROJECT_ROOT%Plugins\GameFeatures

echo Cleaning Unreal Engine project directories...
echo Project root: %PROJECT_ROOT%
echo Plugins directory: %PLUGINS_DIR%
echo Game features directory: %FEATURES_DIR%
echo.

rem Clean project root folders
echo Cleaning project root folders...
call :clean_directory "%PROJECT_ROOT%"

rem Clean each plugin's folders
echo Cleaning plugin folders...
for /d %%p in ("%PLUGINS_DIR%\*") do (
    echo Cleaning plugin: %%p
    call :clean_directory "%%p"
)

echo Cleaning game features folders...
for /d %%p in ("%FEATURES_DIR%\*") do (
    echo Cleaning game feature: %%p
    call :clean_directory "%%p"
)

goto exit0

rem Function to delete folders except Saved/Cooked
:clean_directory
if exist "%~1\Saved" (
    echo Skipping "%~1\Saved\Cooked"
    for /d %%d in ("%~1\Saved\*") do (
        if /i "%%~nxd" neq "Cooked" (
            echo Deleting "%%d"
            rmdir /s /q "%%d"
        )
    )
)
if exist "%~1\Intermediate" (
    echo Deleting "%~1\Intermediate"
    rmdir /s /q "%~1\Intermediate"
)
if exist "%~1\Binaries" (
    echo Deleting "%~1\Binaries"
    rmdir /s /q "%~1\Binaries"
)
exit /b 0

:exit0
echo.
echo Cleaning completed.
exit /b 0
pause
