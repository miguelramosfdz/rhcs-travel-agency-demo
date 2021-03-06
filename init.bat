@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set DEMO=Cloud JBoss Travel Agency Demo
set AUTHORS=Nirja Patel, Shepherd Chengeta,
set AUTHORS2=Andrew Block, Eric D. Schabell
set PROJECT=git@github.com:redhatdemocentral/rhcs-travel-agency-demo.git
set SRC_DIR=%PROJECT_HOME%installs
set OPENSHIFT_USER=openshift-dev
set OPENSHIFT_PWD=devel
set BPMS=jboss-bpmsuite-6.3.0.GA-installer.jar
set EAP=jboss-eap-6.4.0-installer.jar
set EAP_PATCH=jboss-eap-6.4.7-patch.zip

REM wipe screen.
cls

echo.
echo #################################################################
echo ##                                                             ##   
echo ##  Setting up the %DEMO%                          ##
echo ##                                                             ##   
echo ##                                                             ##   
echo ##     ####  ####   #   #      ### #   # ##### ##### #####     ##
echo ##     #   # #   # # # # #    #    #   #   #     #   #         ##
echo ##     ####  ####  #  #  #     ##  #   #   #     #   ###       ##
echo ##     #   # #     #     #       # #   #   #     #   #         ##
echo ##     ####  #     #     #    ###  ##### #####   #   #####     ##
echo ##                                                             ##   
echo ##                       ###   #### #####                      ##
echo ##                  #   #   # #     #                          ##
echo ##                 ###  #   #  ###  ###                        ##
echo ##                  #   #   #     # #                          ##
echo ##                       ###  ####  #####                      ##
echo ##                                                             ##   
echo ##  brought to you by,                                         ##   
echo ##                     %AUTHORS%           ##
echo ##                       %AUTHORS2%          ##
echo ##                                                             ##   
echo ##  %PROJECT%##
echo ##                                                             ##   
echo #################################################################
echo.

REM make some checks first before proceeding.	
call where oc >nul 2>&1
if  %ERRORLEVEL% NEQ 0 (
	echo OpenShift command line tooling is required but not installed yet... download here:
	echo https://access.redhat.com/downloads/content/290
	GOTO :EOF
)

if exist %SRC_DIR%\%EAP% (
        echo Product sources are present...
        echo.
) else (
        echo Need to download %EAP% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

if exist %SRC_DIR%\%EAP_PATCH% (
        echo Product patches are present...
        echo.
) else (
        echo Need to download %EAP_PATCH% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

if exist %SRC_DIR%\%BPMS% (
        echo Product sources are present...
        echo.
) else (
        echo Need to download %BPMS% package from the Customer Support Portal
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

echo OpenShift commandline tooling is installed...
echo.
echo Logging into OSE as %OPENSHIFT_USER%...
echo.
call oc login 10.1.2.2:8443 --password="%OPENSHIFT_PWD%" --username="%OPENSHIFT_USER%"

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc login' command!
	echo.
	GOTO :EOF
)

echo.
echo Creating a new project...
echo.
call oc new-project rhcs-travel-agency-demo 

echo.
echo Setting up a new build...
echo.
call oc new-build "jbossdemocentral/developer" --name=rhcs-travel-agency-demo --binary=true

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc new-build' command!
	echo.
	GOTO :EOF
)

REM need to wait a bit for new build to finish with developer image.
timeout 3 /nobreak

echo.
echo Importing developer image...
echo.
call oc import-image developer

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc import-image' command!
	echo.
	GOTO :EOF
)

echo.
echo Starting a build, this takes some time to upload all of the product sources for build...
echo.
call oc start-build rhcs-travel-agency-demo --from-dir=. --follow=true --wait=true

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc start-build' command!
	echo.
	GOTO :EOF
)

echo.
echo Creating a new application...
echo.
call oc new-app rhcs-travel-agency-demo

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc new-app' command!
	echo.
	GOTO :EOF
)

echo.
echo Creating an externally facing route by exposing a service...
echo.
call oc expose service rhcs-travel-agency-demo --hostname=rhcs-travel-agency-demo.10.1.2.2.xip.io

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc expose service' command!
	echo.
	GOTO :EOF
)

echo.
echo ==================================================================================
echo =                                                                                =
echo =  Login to start exploring the Travel Agency project:                           =
echo =                                                                                =
echo =    http://rhcs-travel-agency-demo.10.1.2.2.xip.io/business-central             =
echo =                                                                                =
echo =    [ u:erics / p:jbossbrms1! ]                                                 =
echo =                                                                                =
echo =                                                                                =
echo =  Access the Cool Store web shopping cart at:                                   =
echo =                                                                                =
echo =    http://rhcs-travel-agency-demo.10.1.2.2.xip.io/external-client-ui-form-1.0  =
echo =                                                                                =
echo =                                                                                =
echo =  Note: it takes a few minutes to expose the service...                         =
echo =                                                                                =
echo ==================================================================================
echo.

