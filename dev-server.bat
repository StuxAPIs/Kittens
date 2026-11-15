@echo off
setlocal enabledelayedexpansion
REM Kittens - Local dev server (Windows)
REM Usage: dev-server.bat [port] [--no-dev-mode] [--lan]
REM   port            default: whatever's in config.json (falls back to 8080)
REM   --no-dev-mode   don't force "localhost" mode on for this run (see below)
REM   --lan           listen on all interfaces so phones/tablets on your network can
REM                   connect (prints the addresses to open); default is 127.0.0.1 only.
REM                   In dev mode, the app's links then use this machine's LAN address
REM                   instead of 127.0.0.1, so they work from the other device too.
REM
REM "localhost" mode is forced ON in config.json for every run of this script,
REM regardless of what config.json has it set to - that's what makes redirect/
REM JSON URLs point at 127.0.0.1 without having to flip it by hand every time.
REM Pass --no-dev-mode to test the app against your real config.json instead.
REM
REM This script also bootstraps config.json from config.json.example if it
REM doesn't exist yet, installs Python dependencies if quart isn't importable,
REM and drops in a placeholder images/ folder if none exists so the app
REM doesn't crash on a fresh checkout (index.py errors out on an empty image
REM folder).

set "DIR=%~dp0"
cd /d "%DIR%"

set "PORT="
set "NO_DEV_MODE=0"
set "LAN=0"

:parse_args
if "%~1"=="" goto args_done
if "%~1"=="--no-dev-mode" (
    set "NO_DEV_MODE=1"
    shift
    goto parse_args
)
if "%~1"=="--lan" (
    set "LAN=1"
    shift
    goto parse_args
)
echo %~1| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo Unknown option: %~1
    echo Usage: dev-server.bat [port] [--no-dev-mode] [--lan]
    exit /b 1
)
set "PORT=%~1"
shift
goto parse_args
:args_done

if not exist "%DIR%config.json" (
    echo No config.json found - copying config.json.example to get you started.
    copy /y "%DIR%config.json.example" "%DIR%config.json" >nul
)

where python >nul 2>&1
if errorlevel 1 (
    echo Python is required but wasn't found on PATH.
    exit /b 1
)

python -c "import quart" >nul 2>&1
if errorlevel 1 (
    echo Installing Python dependencies...
    python -m pip install -r "%DIR%requirements.txt"
)

if not exist "%DIR%images" mkdir "%DIR%images"
dir /b "%DIR%images" | findstr . >nul 2>&1
if errorlevel 1 (
    echo No images found - dropping in a placeholder so the app has something to serve.
    copy /y "%DIR%bin\placeholder_kitten.png" "%DIR%images\placeholder_kitten.png" >nul
)

python "%DIR%bin\dev_configure.py" "%PORT%" "%NO_DEV_MODE%"

if "%LAN%"=="1" (
    for /f %%p in ('python -c "import json; print(json.load(open('config.json'))['port'])"') do set "PORT=%%p"
    set "LAN_ADDR="
    echo On your local network ^(--lan^), open one of these on the other device:
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
        for /f "tokens=* delims= " %%b in ("%%a") do (
            echo     http://%%b:!PORT!/
            if "!LAN_ADDR!"=="" set "LAN_ADDR=%%b"
            echo %%b| findstr /b "192.168." >nul && (echo !LAN_ADDR!| findstr /b "192.168." >nul || set "LAN_ADDR=%%b")
        )
    )
    echo   ^(usually the 192.168.x.x one; allow Python through the firewall if asked^)
    set "KITTENS_DEV_HOST=0.0.0.0"
    REM The app's own links use the 192.168.x.x address if there is one, else the first one found
    if not "!LAN_ADDR!"=="" set "KITTENS_DEV_ADDR=!LAN_ADDR!"
)

python "%DIR%index.py"
