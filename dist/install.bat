@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "INSTALL_DIR=%USERPROFILE%\bin"
set "BACKUP_DIR=%USERPROFILE%\.uniminify-backups"
set "SOURCE_EXEC_NAME=uniminify-win.exe"
set "TARGET_EXEC_NAME=uniminify.exe"

if not exist "%INSTALL_DIR%" (
    echo Creating installation folder: "%INSTALL_DIR%"
    mkdir "%INSTALL_DIR%"
)

if exist "%INSTALL_DIR%\%TARGET_EXEC_NAME%" (
    echo.
    echo WARNING: The command '%TARGET_EXEC_NAME%' already exists.
    echo Backing up the existing version before proceeding...

    if not exist "%BACKUP_DIR%" (
        echo Creating backup directory: "%BACKUP_DIR%"
        mkdir "%BACKUP_DIR%"
    )

    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set "DATETIME=%%I"
    set "TIMESTAMP=%DATETIME:~0,8%_%DATETIME:~8,6%"
    
    copy /Y "%INSTALL_DIR%\%TARGET_EXEC_NAME%" "%BACKUP_DIR%\uniminify_%TIMESTAMP%.exe.bak" >nul
    echo Backup saved to: "%BACKUP_DIR%\uniminify_%TIMESTAMP%.exe.bak"

    echo.
    echo Pressing any key will now overwrite the active file in "%INSTALL_DIR%".
    echo (You can press Ctrl+C to cancel the installation.)
    pause >nul
)

if not exist "%SCRIPT_DIR%%SOURCE_EXEC_NAME%" (
    echo Source executable '%SOURCE_EXEC_NAME%' not found.
    echo Downloading from GitHub...
    set "URL=https://github.com/crazystuffxyz/universal-minifier/releases/download/v2.0.0-binary/%SOURCE_EXEC_NAME%"
    curl.exe -L --silent --show-error --fail --output "%SCRIPT_DIR%%SOURCE_EXEC_NAME%" "%URL%"
    if errorlevel 1 (
        echo ERROR: Download failed. Please check your internet connection or URL.
        pause
        exit /b 1
    )
    echo Download complete.
)

echo Installing new version of %TARGET_EXEC_NAME% to "%INSTALL_DIR%"...
copy /Y "%SCRIPT_DIR%%SOURCE_EXEC_NAME%" "%INSTALL_DIR%\%TARGET_EXEC_NAME%" >nul
if errorlevel 1 (
    echo ERROR: Could not copy %SOURCE_EXEC_NAME%.
    pause
    exit /b 1
) else (
    echo Successfully installed %TARGET_EXEC_NAME%.
)

powershell -NoProfile -Command "$path = [Environment]::GetEnvironmentVariable('PATH', 'User'); $installDir = '%INSTALL_DIR%'; if (-not ($path -split ';' | Where-Object { $_ -eq $installDir })) { $newPath = $path + ';' + $installDir; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); Write-Host 'Added ""%INSTALL_DIR%"" to your user PATH.'; } else { Write-Host '""%INSTALL_DIR%"" is already in your user PATH.'; }"

echo.
echo [DONE] For the PATH change to take effect, please open a new terminal.
echo        Then you can run:
echo        uniminify --help
pause