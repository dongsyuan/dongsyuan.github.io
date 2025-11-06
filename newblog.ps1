# 检查执行策略，如果不是RemoteSigned则临时允许
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -eq "Restricted") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
}

# 设置目标文件夹路径
$targetDir = "F:\myblog\source\_posts"

# 检查并创建目标文件夹
if (!(Test-Path $targetDir)) {
    try {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Write-Host "已创建目录: $targetDir"
    } catch {
        Write-Host "错误：无法创建文件夹 $targetDir"
        Write-Host "错误信息: $($_.Exception.Message)"
        Write-Host "按任意键退出..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
}

# 获取当前时间
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 创建临时文件
$tempFile = Join-Path $targetDir "new_post.md"

# 写入YAML格式内容
@"
---
title: 
time: $currentTime
---

"@ | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "正在打开记事本，请编辑文章内容..."
Write-Host "注意：编辑完成后请保存并关闭记事本"

# 打开记事本
try {
    $process = Start-Process -FilePath "notepad.exe" -ArgumentList $tempFile -PassThru -Wait
} catch {
    Write-Host "错误：无法打开记事本"
    Write-Host "按任意键退出..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# 检查文件是否存在
if (!(Test-Path $tempFile)) {
    Write-Host "错误：文件不存在，操作已取消"
    Write-Host "按任意键退出..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# 读取标题
$title = "未命名文档"
try {
    $content = Get-Content $tempFile -Encoding UTF8
    foreach ($line in $content) {
        if ($line -match '^title:\s*(.+)') {
            $title = $matches[1].Trim()
            break
        }
    }
} catch {
    Write-Host "错误：读取文件失败"
    Write-Host "按任意键退出..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# 清理文件名中的非法字符
$safeTitle = $title -replace '[\\/:*?"<>|]', ''
if ([string]::IsNullOrEmpty($safeTitle)) {
    $safeTitle = "未命名文档"
}

# 处理重名文件
$baseName = $safeTitle
$counter = 1
$finalName = "$baseName.md"
$finalPath = Join-Path $targetDir $finalName

while (Test-Path $finalPath) {
    $finalName = "${baseName}_${counter}.md"
    $finalPath = Join-Path $targetDir $finalName
    $counter++
}

# 重命名文件（如果不是默认名称）
if ($finalName -ne "new_post.md") {
    try {
        Rename-Item -Path $tempFile -NewName $finalName
        Write-Host "文件已创建: $finalName"
    } catch {
        Write-Host "错误：重命名文件失败"
        Write-Host "按任意键退出..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
} else {
    Write-Host "文件已创建但未重命名: $finalName"
}

Write-Host "`n操作完成！"
Write-Host "按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")