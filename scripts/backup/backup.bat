@echo off
REM Supabase Database Backup Script for Windows
REM Usage: backup.bat [output_dir]
REM Default output: .\backups\

setlocal

REM Configuration
set OUTPUT_DIR=%1
if "%OUTPUT_DIR%"=="" set OUTPUT_DIR=.\backups
set DATE=%date:~-4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set DATE=%DATE: =0%
set BACKUP_NAME=seruni_backup_%DATE%.sql.gz
set PROJECT_REF=%SUPABASE_PROJECT_REF%

echo [INFO] Starting database backup...
echo [INFO] Project: %PROJECT_REF%
echo [INFO] Output: %OUTPUT_DIR%\%BACKUP_NAME%

REM Create backup directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%OUTPUT_DIR%\logs" mkdir "%OUTPUT_DIR%\logs"

REM Check for required environment variables
if "%DATABASE_URL%"=="" (
    echo [ERROR] DATABASE_URL not set
    echo Please set DATABASE_URL environment variable
    exit /b 1
)

REM Backup using pg_dump
echo [INFO] Creating backup...
pg_dump "%DATABASE_URL%" | gzip > "%OUTPUT_DIR%\%BACKUP_NAME%"

if %ERRORLEVEL% EQU 0 (
    echo [INFO] Backup created: %BACKUP_NAME%

    REM Get size
    for %%A in ("%OUTPUT_DIR%\%BACKUP_NAME%") do set SIZE=%%~zA
    echo [INFO] Backup size: !SIZE! bytes

    REM Log
    echo %DATE% - %BACKUP_NAME% - !SIZE! bytes >> "%OUTPUT_DIR%\logs\backup.log"

    echo [INFO] Backup complete!
) else (
    echo [ERROR] Backup failed!
    exit /b 1
)

endlocal
