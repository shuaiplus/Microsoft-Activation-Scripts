# ==========================================
# 核心配置：直接从你的域名下载 cmd 文件
$DownloadURL = 'https://get.elyar.de/MAS_AIO.cmd'
# ==========================================

# 1. 设置安全协议，防止旧系统下载失败
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# 2. 准备临时文件路径
$rand = [Guid]::NewGuid().Guid
$FilePath = "$env:TEMP\MAS_$rand.cmd"

# 3. 开始下载
try {
    Write-Host "正在连接 get.elyar.de 下载激活组件..." -ForegroundColor Cyan
    
    # 兼容性下载逻辑
    if ($PSVersionTable.PSVersion.Major -ge 3) {
        # 添加随机参数 ?t=xxx 防止本地缓存
        Invoke-RestMethod -Uri "$DownloadURL?t=$(Get-Date -UFormat %s)" -OutFile $FilePath
    } else {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile("$DownloadURL?t=$(Get-Date -UFormat %s)", $FilePath)
    }
}
catch {
    Write-Host "下载失败！请检查您的网络连接。" -ForegroundColor Red
    Write-Host "错误详情: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# 4. 运行脚本 (请求管理员权限)
if (Test-Path $FilePath) {
    Write-Host "下载成功，正在启动..." -ForegroundColor Green
    
    # 启动 CMD，-Wait 等待执行结束，-Verb RunAs 提权
    $process = Start-Process -FilePath "$env:SystemRoot\system32\cmd.exe" `
        -ArgumentList "/c """"$FilePath"" $args""" `
        -Verb RunAs -PassThru -Wait
    
    # 5. 清理垃圾
    Remove-Item -Path $FilePath -ErrorAction SilentlyContinue
}
