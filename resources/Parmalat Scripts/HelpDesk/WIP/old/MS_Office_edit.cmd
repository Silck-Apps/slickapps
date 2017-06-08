@echo off
echo *******************************************************************************
echo **************     MS Office Registry keys removal tool     *******************
echo *******************************************************************************
echo **                                                                           **
echo ** Use this tool to remove registry keys for any MS office programs listed.  **
echo **                                                                           **
echo **          EG: Aztec toolbar won't load in powerpoint or excel              **
echo **                                                                           **
echo **                  This tool does the same thing as we                      **
echo **                do manually when removing registry keys.                   **
echo *******************************************************************************
echo.
choice /c CE /n /m "(C)ontinue or (E)xit ?"
if errorlevel 2 exit
echo.
set /p _username_=Username? 

for /f %%a in ('getsid %_username_%') do set userSID=%%a

echo.
echo Working .......
echo.
FOR /f "skip=2" %%i IN ('qappsrv') DO (FOR /f %%b IN ('query user %_username_% /server:%%i') DO set user_TSVR=%%i) 2> NUL
for /f "tokens=9" %%i IN ('tsprof /Q /domain:quf %_username_%') DO (for /f "delims=\ tokens=1,2,3,4" %%d IN ('echo %%i') DO set user_prof=\\%%d\%%e\%%f\%%g)

pushd %user_Prof%
FOR /f "delims=\ tokens=3" %%i IN ('dir ntuser.dat /A:H /S /B') DO IF NOT %%i==ntuser.dat set user_prof=%user_prof%\%%i
xcopy ntuser.dat ntuser.dat_copy /H /y
popd
echo.
choice /c EPWO /n /m "Select Component to remove - (E)xcel, (P)owerpoint, (W)ord or (O)utlook: "
if errorlevel 4 set Clean_Prog=outlook
if errorlevel 3 set Clean_Prog=word
if errorlevel 2 set Clean_Prog=powerpoint
if errorlevel 1 set Clean_Prog=excel
echo.
echo Removing all Registry entries for %Clean_Prog% from 
echo HKU\%userSID%\software\microsoft\office on %user_TSVR%
echo.
for /f "delims=\ tokens=6" %%b in ('reg query \\%user_TSVR%\HKU\%userSID%\software\microsoft\office /f .0 /k') do reg delete \\%user_TSVR%\HKU\%userSID%\software\microsoft\office\%%b\%Clean_Prog% /f
for /f %%b in ('reg query \\%user_TSVR%\HKU\%userSID%\software\microsoft\office /f %Clean_Prog% /k') do reg delete \\%user_TSVR%\HKU\%userSID%\software\microsoft\office\%Clean_Prog% /f
echo.
echo process completed. 
echo Please ensure that the user logs off correctly. This will ensure that the registry
echo is written back to the user's profile correctly!!
pause