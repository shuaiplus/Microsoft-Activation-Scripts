# <--- 这一行请保留为空，用来吸收可能存在的 BOM 字符 --->

# 1. 设置安全协议
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# 2. 准备临时路径
$rand = Get-Random
$FilePath = "$env:TEMP\MAS_$rand.cmd"

try {
    Write-Host "正在连接 get.elyar.de 下载激活组件..." -ForegroundColor Cyan
    
    # ==========================================
    # 核心配置：直接定义 URL (移到此处更安全)
    $TargetUrl = "https://get.elyar.de/MAS_AIO.cmd"
    # ==========================================
    
    # 拼接防缓存参数 (使用简单的 &r=随机数)
    $FinalUrl = "$TargetUrl?r=$rand"
    
    # 兼容性下载逻辑
    if ($PSVersionTable.PSVersion.Major -ge 3) {
        Invoke-RestMethod -Uri $FinalUrl -OutFile $FilePath
    } else {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($FinalUrl, $FilePath)
    }
}
catch {
    Write-Host "下载失败！" -ForegroundColor Red
    Write-Host "错误信息: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "尝试链接: $FinalUrl" -ForegroundColor Gray
    return
}

# 3. 运行脚本
if (Test-Path $FilePath) {
    Write-Host "下载成功，正在启动..." -ForegroundColor Green
    
    Start-Process -FilePath "$env:SystemRoot\system32\cmd.exe" `
        -ArgumentList "/c """"$FilePath"" $args""" `
        -Verb RunAs -PassThru -Wait
    
    # 清理
    Remove-Item -Path $FilePath -ErrorAction SilentlyContinue
}
