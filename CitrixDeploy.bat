@echo off
setlocal
REM *************************************************************
REM *************************************************************
REM ***                                                       ***
REM *** (1) CURRENT VERSION OF PACKAGE                        ***
REM ***                                                       ***
set DesiredVersion=19.12.7000.10
REM ***                                                       ***
REM *** (2) PACKAGE LOCATION/DEPLOYMENT DIRECTORY             ***
REM ***                                                       ***
set DeployDirectory=\\[YOUR_IP]\COMMUN\CITRIX
REM ***                                                       ***
REM *** (3) SCRIPT LOGGING DIRECTORY                          ***
REM ***                                                       ***
set logshare=C:\Logs\
REM ***                                                       ***
REM *************************************************************
REM *************************************************************
REM *************************************************************
REM *************************************************************
REM ***                                                       ***
REM ***                                                       ***
REM *** BEGIN SCRIPT PROCESSING                               ***
REM ***                                                       ***
REM ***                                                       ***
REM *************************************************************
REM *************************************************************
REM *************************************************************
REM *************************************************************

If not exist %logshare% mkdir %logshare%

echo %date% %time% the %0 script is running >> %logshare%%ComputerName%.log

REM *************************************************************
REM System verification
REM *************************************************************

REM Check if the machine is 64bit
IF NOT "%ProgramFiles(x86)%"=="" SET WOW6432NODE=WOW6432NODE\

REM This script does not verify if a legacy client is already installed
REM Check if the Desired Citrix Workspace is installed

reg query "HKLM\SOFTWARE\%WOW6432NODE%Citrix\PluginPackages\XenAppSuite\ICA_Client" | findstr %DesiredVersion%
if %errorlevel%==1 (goto NotFound) else (goto Found)
REM If 1 was returned, the registry query found the Desired Version is not installed.


REM *************************************************************
REM Deployment begins here
REM *************************************************************

:NotFound
echo Installations en cours...

xcopy %DeployDirectory%\ReceiverCleanupUtility.exe %TEMP%\ReceiverCleanupUtility\ /y /v /q
start /wait %TEMP%\ReceiverCleanupUtility\ReceiverCleanupUtility.exe /silent
start /wait %DeployDirectory%\CitrixWorkspaceApp.exe /SILENT /noreboot /rcu /AutoUpdateCheck=manual /AutoUpdateStream=LTSR
reg import %DeployDirectory%\WorkspaceNoAutoupdate.reg

echo %date% %time% Setup ended with error code %errorlevel%. >> %logshare%%ComputerName%.log
type %temp%\TrolleyExpress*.log >> %logshare%%ComputerName%.log
goto End

:Found
echo %date% %time% Package was detected, Halting >> %logshare%%ComputerName%.log
goto End


:End
echo %date% %time% the %0 script has completed successfully >> %logshare%%ComputerName%.log
Endlocal
exit