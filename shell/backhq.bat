echo off

echo ********开始备份日志文件********

rem set /a mon=%date:~5,2%
rem set /a day=%date:~8,2%
rem if %day% gtr 9 set ymd=%date:~0,4%-%date:~5,2%-%date:~8,2%
rem set ymd=%date:~0,4%-%mon%-%day%

rem 获取昨天日期
set YE=%date:~0,4%
set MO=%date:~5,2%
set DA=%date:~8,2%
set DG=1
set/a vY1=%YE% %% 400
set/a vY2=%YE% %% 4
set/a vY3=%YE% %% 100
if %vY1%==0 (set var=true) else (if %vY2%==0 (if %vY3%==0 (set var=false) else (set var=true)) else (set var=false))
set LY=%YE%
set LM=%MO%
if %MO:~0,1%==0 (set MO=%MO:~1,1%)
if %DA:~0,1%==0 (set DA=%DA:~1,1%)
if %DA% GTR %DG% (set/a LD=%DA%-%DG%) else (
if %MO%==1 (set /a LY=%YE%-1) & (set /a LM=12+%MO%-1) & (set /a LD=31+%DA%-%DG%) else (
set/a LM=%MO%-1
if %MO%==3 (if %var%==false (set /a LD=28+%DA%-%DG%) else (set /a LD=29+%DA%-%DG%))
for %%a in (2 4 6 8 9 11) do (if "%MO%"=="%%a" (set/a LD=31+%DA%-%DG%))
for %%b in (5 7 8 10 12) do (if "%MO%"=="%%b" (set/a LD=30+%DA%-%DG%))))
if %LM% LSS 10 set LM=%LM:~-1%
if %LD% LSS 10 set LD=%LD:~-1%
set ymd=
set ymd=%LY%-%LM%-%LD%
echo %ymd%



set backup-dir=F:\hq

echo ********备份日期:%ymd%********
echo ********备份根目录:%backup-dir%********

set backupsh=%backup-dir%\sh
set backupshsz=%backup-dir%\shbackszxx

echo %backupsh%
echo %backupshsz%

echo ********开始备份SH日志文件********
echo 备份目录：%backupsh%\%ymd%
echo --------------------------------
if not exist %backupsh% (
mkdir %backupsh%
)

cd /D G:\hq\sh
if exist %ymd% (
	echo "7z sh "
	rem C:\Program Files\7-Zip\7z.exe a %backupsh%\%ymd%.7z %ymd%
)

echo *********SH日志备份完成!*********

echo ********开始备份SHSZ日志文件********
echo 备份目录：%backupshsz%\%ymd%
echo --------------------------------
if not exist %backupshsz% (
mkdir %backupshsz%
)

rem if exist %backupsh%\%ymd%.7z del %backupsh%\%ymd%.7z

cd /D G:\hq\shbacksz
if exist %ymd% (
	echo "7z sh  "
	rem C:\Program Files\7-Zip\7z.exe a %backupshsz%\%ymd%.7z %ymd%
)
echo *********SHSZ日志备份完成!*********

rem pause
echo