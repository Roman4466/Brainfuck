@ECHO OFF
echo.>test.res
echo === test1.b ===>>test.res
entry test1.b >>test.res

@REM echo.>>test.res
@REM echo === test2.b ===>>test.res
@REM echo abcde| entry test2.b >>test.res

@REM echo.>>test.res
@REM echo === test3.b ===>>test.res
@REM echo 58�3�91| entry test3.b >>test.res

echo.>>test.res
echo === test4.b ===>>test.res
entry test4.b >>test.res

fc /b test.res test.ok
