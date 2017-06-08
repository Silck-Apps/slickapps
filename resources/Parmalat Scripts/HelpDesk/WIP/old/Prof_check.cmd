@echo off
setlocal
set log_file=M:\logs\ntuser_delete.log

set /p _username_=Enter username: 

for /f "tokens=9" %%i IN ('tsprof /Q /domain:quf %_username_%') DO (for /f "delims=\ tokens=1,2,3,4" %%d IN ('echo %%i') DO set user_prof=\\%%d\%%e\%%f\%%g)

pushd %user_Prof%
FOR /f "delims=\ tokens=3*" %%i IN ('dir ntuser.dat /A:H /S /B') DO IF NOT %%i==ntuser.dat set user_prof=%user_prof%\win2k3
popd

reg load hklm\temp %user_Prof%\ntuser.dat >NUL
set state=%errorlevel%
if "%state%" == "1" (del %user_prof%\ntuser.dat /f /a:h
		     echo deleted ntuser.dat Username: %_username_% When: %date% >> %log_file% 
		     echo.
		     Echo Deleted NTuser.dat for %_username_%. Check %log_file% for details. 
		     echo.
		     pause)
if "%state%" == "0" (echo.
		     echo NTuser.dat for %_username_% is OK. No changes Made 
		     echo.
		     pause)
reg unload hklm\temp >NUL