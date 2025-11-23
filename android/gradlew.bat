@rem Gradle start up script for Windows.
@rem This version checks for the wrapper JAR and emits guidance when missing so
@rem the repo can avoid committing binary wrapper artifacts.

@if "%DEBUG%"=="" @echo off
@setlocal

set DIR=%~dp0
if exist "%DIR%gradle\wrapper\gradle-wrapper.jar" goto wrapperJarPresent

echo [gradlew.bat] gradle-wrapper.jar is missing.
echo [gradlew.bat] Generate it once with: gradle wrapper --gradle-version 8.2.1
exit /B 1

:wrapperJarPresent
set APP_BASE_NAME=%~n0
set APP_HOME=%DIR%

set DEFAULT_JVM_OPTS=

if not "%JAVA_HOME%"=="" goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo [gradlew.bat] JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo [gradlew.bat] Please install JDK 17+ and try again.
exit /B 1

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%\bin\java.exe

if exist "%JAVA_EXE%" goto execute

echo [gradlew.bat] JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo [gradlew.bat] Please set the JAVA_HOME variable to your Java installation.
exit /B 1

:execute
set CLASSPATH=%DIR%gradle\wrapper\gradle-wrapper.jar

%JAVA_EXE% %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

:end
@endlocal
