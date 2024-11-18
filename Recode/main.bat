@echo off
title CP MultiTool - by NRGJobro
chcp 65001 >nul
set "scriptDir=%~dp0"   :: Get the directory where the batch script is running
color 5

:start
call :banner

:menu
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%A
	     echo.
	     echo.
       	     echo [38;2;255;255;0m        ╔═(1) Disable Services [0m  
	     echo [38;2;255;255;0m        ║[0m  
	     echo [38;2;255;255;0m        ╠══(2) Update Services [0m  
	     echo [38;2;255;255;0m        ║[0m  
	     echo [38;2;255;255;0m        ╠═══(3) Remove Services and MP3s [0m  
	     echo [38;2;255;255;0m        ║[0m  
	     echo [38;2;255;255;0m        ╠════(4) User Management [0m  
	     echo [38;2;255;255;0m        ║[0m  
	     echo [38;2;255;255;0m        ╠═════(5) Registry Management [0m  
	     echo [38;2;255;255;0m        ║[0m  
	     echo [38;2;255;255;0m        ╠══════(6) Misc [0m  
	     echo [38;2;255;255;0m        ║[0m  
	     echo [38;2;255;255;0m        ╚╦══════(a) Run All [0m  
	     echo [38;2;255;255;0m         ║[0m  
set /p input=.%BS% [38;2;255;255;0m        ╚══════^>[0m  
set "filePath=%scriptDir%files"

if /I %input% EQU 1 (
     start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\1-Disable\AllCommands.ps1"
)

if /I %input% EQU 2 (
     start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\2-Updates\AllCommands.ps1"
)

if /I %input% EQU 3 (
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\3-Delete\AllCommands.ps1"
)

if /I %input% EQU 4 (
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\4-UserManagement\AllCommands.ps1"
)

if /I %input% EQU 5 (
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\5-RegistryManagement\AllCommands.ps1"
)

if /I %input% EQU 6 (
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\6-Misc\AllCommands.ps1"
)

if /I %input% EQU a (
    echo Running all tasks...
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\1-Disable\AllCommands.ps1"
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\2-Updates\AllCommands.ps1"
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\3-Delete\AllCommands.ps1"
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\4-UserManagement\AllCommands.ps1"
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\5-RegistryManagement\AllCommands.ps1"
    start "" powershell.exe -ExecutionPolicy Bypass -File "%filePath%\6-Misc\AllCommands.ps1"
)

cls
goto start

:banner
echo.
echo.
  echo            [38;2;255;0;0m ██████╗██████╗     ███╗   ███╗██╗   ██╗██╗  ████████╗██╗    ████████╗ ██████╗  ██████╗ ██╗[0m     
 echo            [38;2;255;51;0m██╔════╝██╔══██╗    ████╗ ████║██║   ██║██║  ╚══██╔══╝██║    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     [0m
echo            [38;2;255;102;0m██║     ██████╔╝    ██╔████╔██║██║   ██║██║     ██║   ██║       ██║   ██║   ██║██║   ██║██║    [0m 
echo            [38;2;255;153;0m██║     ██╔═══╝     ██║╚██╔╝██║██║   ██║██║     ██║   ██║       ██║   ██║   ██║██║   ██║██║     [0m
echo            [38;2;255;204;0m╚██████╗██║         ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║       ██║   ╚██████╔╝╚██████╔╝███████╗[0m
echo            [38;2;255;255;0m ╚═════╝╚═╝         ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝[0m
echo.
