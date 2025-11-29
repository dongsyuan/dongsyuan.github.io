@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: 目标文件夹路径
set "target_dir=F:\myblog\source\_posts"

:: 检查并创建目标文件夹
if not exist "%target_dir%" (
    mkdir "%target_dir%" >nul 2>&1
    if errorlevel 1 (
        echo 错误：无法创建文件夹 %target_dir%
        echo 请检查路径是否正确或权限是否足够
        timeout /t 3 /nobreak >nul
        exit /b 1
    )
)

:: 获取当前时间
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value 2^>nul') do set "dt=%%a"
if not defined dt (
    set "dt=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%"
    set "dt=!dt: =0!"
)
set "time_str=!dt:~0,4!-!dt:~4,2!-!dt:~6,2! !dt:~8,2!:!dt:~10,2!:!dt:~12,2!"

:: 创建临时文件
set "temp_name=temp_%random%%random%.md"
set "temp_file=%target_dir%\%temp_name%"

:: 写入YAML格式内容，并在其后添加两个空行
(
    echo ---
    echo title: 
    echo time: %time_str%
    echo ---
    echo.
    echo.
) > "%temp_file%"

:: 打开记事本编辑
notepad "%temp_file%"

:: 等待记事本关闭
:wait_close
timeout /t 1 /nobreak >nul
tasklist /fi "imagename eq notepad.exe" | find /i "notepad.exe" >nul
if not errorlevel 1 (
    goto wait_close
)

:: 检查文件是否存在
if not exist "%temp_file%" (
    echo 错误：临时文件不存在
    timeout /t 3 /nobreak >nul
    exit /b 1
)

:: 读取标题 - 修复的核心部分
set "title="
for /f "usebackq delims=" %%i in ("%temp_file%") do (
    set "line=%%i"
    :: 检查是否是title行
    if /i "!line:~0,6!"=="title:" (
        set "title=!line:~6!"
        :: 去除前导空格
        :trim_loop
        if "!title:~0,1!"==" " (
            set "title=!title:~1!"
            goto trim_loop
        )
        goto title_found
    )
)

:title_found

:: 检查标题是否为空
if "!title!"=="" (
    echo 未输入标题，取消文件生成
    del "%temp_file%" >nul 2>&1
    echo 临时文件已删除
    timeout /t 3 /nobreak >nul
    exit /b 0
)

:: 清理文件名中的非法字符
set "safe_title=!title!"
for %%c in ("\" "/" ":" "*" "?" "<" ">" "|") do (
    set "safe_title=!safe_title:%%~c=!"
)

:: 处理重名文件
set "base_name=!safe_title!"
set "counter=1"
set "final_name=!base_name!.md"

:check_name
if exist "%target_dir%\!final_name!" (
    set "final_name=!base_name!_!counter!.md"
    set /a counter+=1
    goto check_name
)

:: 重命名文件
move "%temp_file%" "%target_dir%\!final_name!" >nul

:: 显示结果
echo 文件已创建: !final_name!

:: 3秒后关闭
timeout /t 3 /nobreak >nul
endlocal