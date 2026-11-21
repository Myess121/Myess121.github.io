param([string]$ProjectRoot = $PSScriptRoot)

$ErrorActionPreference = 'Stop'
$script:BlogRoot = [IO.Path]::GetFullPath($ProjectRoot)
$script:Utf8 = New-Object Text.UTF8Encoding($false)
$script:Preview = $null
$script:Job = $null

function Quote-Argument([string]$Value) {
    '"' + [regex]::Replace([regex]::Replace($Value, '(\\*)"', '$1$1\"'), '(\\+)$', '$1$1') + '"'
}

function Start-BlogProcess([string]$Command, [string[]]$Arguments) {
    $exe = Get-Command $Command -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = $exe.Source
    $info.Arguments = ($Arguments | ForEach-Object { Quote-Argument $_ }) -join ' '
    $info.WorkingDirectory = $script:BlogRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.StandardOutputEncoding = $script:Utf8
    $info.StandardErrorEncoding = $script:Utf8
    if ($Command -eq 'git') { $info.EnvironmentVariables['GIT_TERMINAL_PROMPT'] = '0' }
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $info
    [void]$process.Start()
    [pscustomobject]@{
        Process = $process
        Output = $process.StandardOutput.ReadToEndAsync()
        Error = $process.StandardError.ReadToEndAsync()
    }
}

function Read-BlogResult($Handle) {
    $Handle.Process.WaitForExit()
    [pscustomobject]@{
        ExitCode = $Handle.Process.ExitCode
        Output = $Handle.Output.GetAwaiter().GetResult()
        Error = $Handle.Error.GetAwaiter().GetResult()
    }
}

function Get-DraftInfo([string]$Title, [string]$Slug, [string]$Category, [bool]$Math) {
    $Title = $Title.Trim()
    $Slug = $Slug.Trim()
    if (-not $Title) { throw '请先填写文章标题。' }
    if (-not $Slug) { $Slug = 'post-' + (Get-Date -Format 'yyyyMMdd-HHmmss') }
    if ($Slug -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        throw '网址名请用英文小写、数字和短横线，或者留空自动命名。'
    }
    if ($Category -notin @('学学习', '碎碎念')) { throw '请选择一个分类。' }
    $directory = Join-Path $script:BlogRoot "content\post\$Slug"
    if (Test-Path -LiteralPath $directory) { throw '这个网址名已经有文章了，请换一个。' }
    [pscustomobject]@{
        Title = $Title; Slug = $Slug; Category = $Category; Math = $Math
        File = Join-Path $directory 'index.md'
    }
}

function Complete-Draft($Draft) {
    $text = [IO.File]::ReadAllText($Draft.File, $script:Utf8)
    $parts = [regex]::Match($text, '\A---\r?\n(?<front>.*?)\r?\n---(?<body>.*)\z', 'Singleline')
    if (-not $parts.Success) { throw '文章已创建，但文章模板的格式无法识别。请打开文件检查。' }
    $front = $parts.Groups['front'].Value
    $titleLine = 'title: ' + (ConvertTo-Json -InputObject $Draft.Title -Compress)
    $slugLine = 'slug: "' + $Draft.Slug + '"'
    $categoryLines = "categories:`n    - " + $Draft.Category
    $front = [regex]::Replace($front, '(?m)^title:.*$', [Text.RegularExpressions.MatchEvaluator]{ param($m) $titleLine })
    $front = [regex]::Replace($front, '(?m)^slug:.*$', [Text.RegularExpressions.MatchEvaluator]{ param($m) $slugLine })
    $front = [regex]::Replace($front, '(?m)^description:.*$', 'description: ""')
    $front = [regex]::Replace($front, '(?m)^categories:\s*\r?\n(?:[ \t]+.*\r?\n?)+', [Text.RegularExpressions.MatchEvaluator]{ param($m) $categoryLines + "`n" })
    $front = [regex]::Replace($front, '(?m)^math:.*$', ('math: ' + $Draft.Math.ToString().ToLowerInvariant()))
    $front = [regex]::Replace($front, '(?m)^draft:.*$', 'draft: true')
    [IO.File]::WriteAllText($Draft.File, "---`n" + $front.TrimEnd() + "`n---" + $parts.Groups['body'].Value, $script:Utf8)
}

function Test-PreviewPort {
    @([Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners() |
        Where-Object { $_.Port -eq 1313 }).Count -gt 0
}

function Start-Preview([bool]$OpenBrowser = $true) {
    if ($script:Preview -and -not $script:Preview.Process.HasExited) { return }
    if (Test-PreviewPort) { throw '1313 端口已被占用。请先关闭原来的本地预览，再打开这里的开关。' }
    $arguments = @('server', '-D', '--bind', '127.0.0.1', '--port', '1313', '--renderToMemory', '--noBuildLock')
    if ($OpenBrowser) { $arguments += '--openBrowser' }
    $script:PreviewReady = $false
    $script:Preview = Start-BlogProcess 'hugo' $arguments
}

function Stop-Preview {
    if ($script:Preview) {
        if (-not $script:Preview.Process.HasExited) {
            # Only stop the Hugo process started by this window.
            $script:Preview.Process.Kill()
            $script:Preview.Process.WaitForExit()
        }
        $script:Preview.Process.Dispose()
        $script:Preview = $null
    }
}

function Open-Draft([string]$File) {
    $editor = Get-Command code.cmd -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($editor) {
        Start-Process -FilePath $editor.Source -ArgumentList ('--reuse-window ' + (Quote-Argument $File)) -WindowStyle Hidden
    } else {
        Start-Process -FilePath notepad.exe -ArgumentList (Quote-Argument $File)
    }
}

function Show-ToolError([string]$Message) {
    $script:Status.Text = '操作未完成，详情见提示。'
    [void][Windows.Forms.MessageBox]::Show($script:Form, $Message, '博客小工具', 'OK', 'Error')
}

function Set-ToolBusy([bool]$Busy, [string]$Message) {
    $script:Create.Enabled = -not $Busy
    $script:Publish.Enabled = -not $Busy
    if ($Message) { $script:Status.Text = $Message }
}

function Start-ToolJob([string]$Command, [string[]]$Arguments, [scriptblock]$Success, [string]$Message) {
    try {
        $handle = Start-BlogProcess $Command $Arguments
        $script:Job = @{ Handle = $handle; Success = $Success }
        Set-ToolBusy $true $Message
    } catch {
        Set-ToolBusy $false ''
        Show-ToolError $_.Exception.Message
    }
}

function Start-GitJob([string[]]$Arguments, [scriptblock]$Success, [string]$Message) {
    Start-ToolJob 'git' (@('-c', 'core.quotepath=false') + $Arguments) $Success $Message
}

function Confirm-Publish([string]$Changes) {
    $dialog = New-Object Windows.Forms.Form
    $dialog.Text = '确认发布到网站'
    $dialog.ClientSize = New-Object Drawing.Size(500, 355)
    $dialog.StartPosition = 'CenterParent'
    $dialog.FormBorderStyle = 'FixedDialog'
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    $dialog.Font = $script:Form.Font
    $label = New-Object Windows.Forms.Label
    $label.SetBounds(18, 15, 464, 42)
    $label.Text = "将提交下面的全部改动，并推送到 GitHub。`n草稿不会在网站显示；已有提交也会一并推送。"
    $files = New-Object Windows.Forms.TextBox
    $files.SetBounds(18, 65, 464, 170)
    $files.Multiline = $true
    $files.ScrollBars = 'Both'
    $files.ReadOnly = $true
    $files.WordWrap = $false
    $files.Text = $Changes.Trim() -replace '\r?\n', "`r`n"
    $message = New-Object Windows.Forms.TextBox
    $message.SetBounds(18, 250, 464, 27)
    $message.Text = '更新博客 ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')
    $ok = New-Object Windows.Forms.Button
    $ok.SetBounds(264, 300, 105, 34)
    $ok.Text = '确认发布'
    $ok.DialogResult = 'OK'
    $cancel = New-Object Windows.Forms.Button
    $cancel.SetBounds(377, 300, 105, 34)
    $cancel.Text = '取消'
    $cancel.DialogResult = 'Cancel'
    $dialog.Controls.AddRange(@($label, $files, $message, $ok, $cancel))
    $dialog.CancelButton = $cancel
    $result = $dialog.ShowDialog($script:Form)
    $commitMessage = $message.Text.Trim()
    $dialog.Dispose()
    if ($result -eq 'OK') {
        if (-not $commitMessage) { $commitMessage = '更新博客' }
        return $commitMessage
    }
    return $null
}

function Push-Blog {
    Start-GitJob @('push') {
        $script:Status.Text = '已推送。网站正在构建，通常需要 1～3 分钟。'
        Start-Process 'https://github.com/Myess121/Myess121.github.io/actions'
    } '正在推送到 GitHub……'
}

function Show-BlogTool {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [Windows.Forms.Application]::EnableVisualStyles()
    if (-not (Test-Path -LiteralPath (Join-Path $script:BlogRoot 'archetypes\post.md'))) {
        [void][Windows.Forms.MessageBox]::Show('请把小工具和 blog-tool.ps1 放在博客根目录。', '博客小工具')
        return
    }

    # A second double-click must not create another preview owner.
    $keyBytes = [Text.Encoding]::UTF8.GetBytes($script:BlogRoot.ToLowerInvariant())
    $sha = [Security.Cryptography.SHA256]::Create()
    $key = ([BitConverter]::ToString($sha.ComputeHash($keyBytes))).Replace('-', '')
    $sha.Dispose()
    $created = $false
    $mutex = New-Object Threading.Mutex($true, ('Local\MyessBlogTool-' + $key), [ref]$created)
    if (-not $created) {
        [void][Windows.Forms.MessageBox]::Show('小工具已经打开了，请查看任务栏。', '博客小工具')
        $mutex.Dispose()
        return
    }

    $script:Form = New-Object Windows.Forms.Form
    $script:Form.Text = 'Myess · 博客小工具'
    $script:Form.ClientSize = New-Object Drawing.Size(484, 418)
    $script:Form.StartPosition = 'CenterScreen'
    $script:Form.FormBorderStyle = 'FixedSingle'
    $script:Form.MaximizeBox = $false
    $script:Form.Font = New-Object Drawing.Font('Microsoft YaHei UI', 9)
    $script:Form.BackColor = [Drawing.Color]::FromArgb(247, 248, 250)

    $heading = New-Object Windows.Forms.Label
    $heading.SetBounds(22, 18, 440, 27)
    $heading.Text = '博客小工具'
    $heading.Font = New-Object Drawing.Font('Microsoft YaHei UI', 13, [Drawing.FontStyle]::Bold)
    $titleLabel = New-Object Windows.Forms.Label
    $titleLabel.SetBounds(22, 61, 75, 25)
    $titleLabel.Text = '文章标题'
    $script:TitleBox = New-Object Windows.Forms.TextBox
    $script:TitleBox.SetBounds(100, 57, 362, 28)
    $slugLabel = New-Object Windows.Forms.Label
    $slugLabel.SetBounds(22, 101, 78, 25)
    $slugLabel.Text = '网址名'
    $script:SlugBox = New-Object Windows.Forms.TextBox
    $script:SlugBox.SetBounds(100, 97, 218, 28)
    $slugHint = New-Object Windows.Forms.Label
    $slugHint.SetBounds(326, 101, 137, 25)
    $slugHint.Text = '选填，留空自动命名'
    $slugHint.ForeColor = [Drawing.Color]::DimGray
    $categoryLabel = New-Object Windows.Forms.Label
    $categoryLabel.SetBounds(22, 141, 75, 25)
    $categoryLabel.Text = '分类'
    $script:Category = New-Object Windows.Forms.ComboBox
    $script:Category.SetBounds(100, 137, 130, 28)
    $script:Category.DropDownStyle = 'DropDownList'
    $script:Category.AccessibleName = '分类'
    [void]$script:Category.Items.AddRange(@('学学习', '碎碎念'))
    $script:Category.SelectedIndex = 0
    $script:Math = New-Object Windows.Forms.CheckBox
    $script:Math.SetBounds(250, 138, 160, 27)
    $script:Math.Text = '这篇文章有公式'
    $script:Create = New-Object Windows.Forms.Button
    $script:Create.SetBounds(100, 177, 362, 36)
    $script:Create.Text = '创建草稿并打开编辑'
    $note = New-Object Windows.Forms.Label
    $note.SetBounds(100, 220, 364, 25)
    $note.Text = '新文章默认草稿，发布前把 draft 改为 false。'
    $note.ForeColor = [Drawing.Color]::DimGray

    $script:Toggle = New-Object Windows.Forms.CheckBox
    $script:Toggle.SetBounds(22, 259, 155, 36)
    $script:Toggle.Appearance = 'Button'
    $script:Toggle.TextAlign = 'MiddleCenter'
    $script:Toggle.Text = '本地预览：关'
    $openPreview = New-Object Windows.Forms.Button
    $openPreview.SetBounds(188, 259, 130, 36)
    $openPreview.Text = '打开预览页'
    $openSite = New-Object Windows.Forms.Button
    $openSite.SetBounds(329, 259, 133, 36)
    $openSite.Text = '打开线上网站'
    $folder = New-Object Windows.Forms.Button
    $folder.SetBounds(22, 306, 155, 36)
    $folder.Text = '文章文件夹'
    $script:Publish = New-Object Windows.Forms.Button
    $script:Publish.SetBounds(188, 306, 274, 36)
    $script:Publish.Text = '发布到网站…'
    $script:Status = New-Object Windows.Forms.Label
    $script:Status.SetBounds(22, 356, 440, 46)
    $script:Status.Text = '预览包含草稿；关掉小工具也会停止预览。'
    $script:Status.ForeColor = [Drawing.Color]::FromArgb(70, 80, 95)
    $script:Form.Controls.AddRange(@($heading, $titleLabel, $script:TitleBox, $slugLabel, $script:SlugBox, $slugHint, $categoryLabel, $script:Category, $script:Math, $script:Create, $note, $script:Toggle, $openPreview, $openSite, $folder, $script:Publish, $script:Status))

    $script:Create.Add_Click({
        try {
            $script:PendingDraft = Get-DraftInfo $script:TitleBox.Text $script:SlugBox.Text $script:Category.Text $script:Math.Checked
            Start-ToolJob 'hugo' @('new', 'content', ('post/' + $script:PendingDraft.Slug + '/index.md')) {
                Complete-Draft $script:PendingDraft
                $script:Status.Text = '草稿已创建。图片放在这篇文章的同一个文件夹。'
                Open-Draft $script:PendingDraft.File
                $script:TitleBox.Clear()
                $script:SlugBox.Clear()
            } '正在创建草稿……'
        } catch { Show-ToolError $_.Exception.Message }
    })
    $script:Toggle.Add_CheckedChanged({
        try {
            if ($script:Toggle.Checked) {
                Start-Preview
                $script:Toggle.Text = '本地预览：开'
                $script:Status.Text = '预览正在启动，准备好后会自动打开浏览器。'
            } else {
                Stop-Preview
                $script:Toggle.Text = '本地预览：关'
                $script:Status.Text = '本地预览已停止。'
            }
        } catch {
            $script:Toggle.Checked = $false
            Show-ToolError $_.Exception.Message
        }
    })
    $openPreview.Add_Click({
        if (-not $script:Toggle.Checked) { $script:Toggle.Checked = $true }
        elseif ($script:Preview -and -not $script:Preview.Process.HasExited) { Start-Process 'http://localhost:1313/' }
    })
    $openSite.Add_Click({ Start-Process 'https://Myess121.github.io/' })
    $folder.Add_Click({ Start-Process explorer.exe -ArgumentList (Quote-Argument (Join-Path $script:BlogRoot 'content\post')) })
    $script:Publish.Add_Click({
        Start-ToolJob 'hugo' @('--gc', '--minify') {
            Start-GitJob @('status', '--short') {
                $changes = $args[0].Output
                $display = $changes
                if (-not $display.Trim()) { $display = '没有未提交的文件。确认后将尝试推送已有提交。' }
                $script:CommitMessage = Confirm-Publish $display
                if ($null -eq $script:CommitMessage) { $script:Status.Text = '已取消发布。'; return }
                if (-not $changes.Trim()) { Push-Blog; return }
                Start-GitJob @('add', '--all') {
                    Start-GitJob @('commit', '-m', $script:CommitMessage) { Push-Blog } '正在保存本地版本……'
                } '正在准备提交……'
            } '正在检查待发布的改动……'
        } '正在检查网站能否生成……'
    })

    $timer = New-Object Windows.Forms.Timer
    $timer.Interval = 200
    $timer.Add_Tick({
        if ($script:Job -and $script:Job.Handle.Process.HasExited -and $script:Job.Handle.Output.IsCompleted -and $script:Job.Handle.Error.IsCompleted) {
            $job = $script:Job
            $script:Job = $null
            try {
                $result = Read-BlogResult $job.Handle
                Set-ToolBusy $false ''
                if ($result.ExitCode -ne 0) {
                    $details = ($result.Error + "`n" + $result.Output).Trim()
                    throw "操作失败（退出码 $($result.ExitCode)）。`n`n$details"
                }
                & $job.Success $result
            } catch { Show-ToolError $_.Exception.Message }
            finally { $job.Handle.Process.Dispose() }
        }
        if ($script:Preview -and $script:Preview.Process.HasExited) {
            $result = Read-BlogResult $script:Preview
            Stop-Preview
            $script:Toggle.Checked = $false
            if ($result.ExitCode -ne 0) { Show-ToolError (($result.Error + "`n" + $result.Output).Trim()) }
        }
        if ($script:Preview -and -not $script:PreviewReady -and (Test-PreviewPort)) {
            $script:PreviewReady = $true
            if (-not $script:Job) { $script:Status.Text = '预览已开启，保存文章后浏览器会自动刷新。' }
        }
    })
    $script:Form.Add_FormClosing({
        if ($script:Job) {
            $_.Cancel = $true
            [void][Windows.Forms.MessageBox]::Show($script:Form, '当前操作还在进行，请等完成后再关闭。', '博客小工具')
        }
    })
    try {
        $timer.Start()
        [void]$script:Form.ShowDialog()
    } finally {
        $timer.Stop()
        $timer.Dispose()
        Stop-Preview
        $script:Form.Dispose()
        $mutex.ReleaseMutex()
        $mutex.Dispose()
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    try { Show-BlogTool }
    catch {
        Add-Type -AssemblyName System.Windows.Forms
        [void][Windows.Forms.MessageBox]::Show($_.Exception.Message, '博客小工具启动失败', 'OK', 'Error')
    }
}
