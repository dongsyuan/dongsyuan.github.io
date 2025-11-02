@echo off
echo 正在切换到F:/myblog文件夹...
cd /d F:/myblog

if %errorlevel% equ 0 (
    echo 开始执行Hexo命令...
    hexo c
    hexo g
    hexo d
) else (
    echo 错误：无法切换到F:/myblog文件夹，请检查路径是否正确
)

echo 操作完成，5秒后自动关闭终端...
timeout /t 5 /nobreak >nul
exit