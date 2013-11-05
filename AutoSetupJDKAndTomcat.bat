@echo off

set TomcatServiceName=Tomcat7
:: Close and remove tomcat service
sc query %TomcatServiceName% >nul 2>nul
if not errorlevel 1 (goto CloseAndRemoveService) else goto StartSetup
:CloseAndRemoveService
echo Stop and remove %TomcatServiceName% service
net stop %TomcatServiceName%
sc delete %TomcatServiceName%

:StartSetup
:: init environment vars
set javaDisk=d:
set javaFolder=d:\Java
set jdkSourceFolderName=jdk1.7.0_25
set jdkSourceFolderPath=%cd%\%jdkSourceFolderName%
set jdkTargetFolderPath=%javafolder%\%jdkSourceFolderName%

:: copy JDK to setted folder
echo copy JDK to environment folder
if exist %jdkTargetFolderPath% rd /s /q %jdkTargetFolderPath%
xcopy %jdkSourceFolderPath% /v /f /e %jdkTargetFolderPath%\

:: set environment variables
cls
echo set environment variables

echo set JAVA_HOME
wmic ENVIRONMENT where "name='JAVA_HOME'" delete
wmic ENVIRONMENT create name="JAVA_HOME",username="<system>",VariableValue="%jdkTargetFolderPath%"
echo set JAVA_HOME successful

echo set JRE_HOME
wmic ENVIRONMENT where "name='JRE_HOME'" delete
wmic ENVIRONMENT create name="JRE_HOME",username="<system>",VariableValue="%jdkTargetFolderPath%\jre"
echo set JRE_HOME successful

echo set PATH
set currpath=%Path%
set currpath=%currpath:;%JAVA_HOME%\bin=%;%%JAVA_HOME%%\bin
wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%currpath%"
echo set PATH successful

echo Java environment install successful

:: Setup Tomcat
set tomcatSourceFoderName=apache-tomcat-7.0.47-windows-x64
set tomcatSourceFolderPath=%cd%\%tomcatSourceFoderName%
set tomcatTargetFolderPath=%javafolder%\%tomcatSourceFoderName%

echo start copy Tomcat to %tomcatTargetFolderPath%
if exist %tomcatTargetFolderPath% rd /s /q %tomcatTargetFolderPath%
xcopy %tomcatSourceFolderPath% /v /f /e %tomcatTargetFolderPath%\

echo setup %TomcatServiceName% Windows Service
%javaDisk%
cd %tomcatTargetFolderPath%\bin
sc query %TomcatServiceName% >nul 2>nul
if not errorlevel 1 (goto DeleteService) else goto SetupService
:DeleteService
call service.bat remove %TomcatServiceName%
:SetupService
call service.bat install %TomcatServiceName%
echo successful setup Tomcat 7 Windows Service

net start %TomcatServiceName%

echo Maybe you need to restart your computer to active environment setting

pause