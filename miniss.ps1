Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$bg0        = [System.Drawing.Color]::FromArgb(7,   11,  20)
$bg1        = [System.Drawing.Color]::FromArgb(11,  18,  34)
$bg2        = [System.Drawing.Color]::FromArgb(16,  26,  50)
$accent     = [System.Drawing.Color]::FromArgb(30,  120, 255)
$accentHi   = [System.Drawing.Color]::FromArgb(80,  160, 255)
$accentGlow = [System.Drawing.Color]::FromArgb(15,  55,  130)
$accentDim  = [System.Drawing.Color]::FromArgb(20,  40,  90)
$warn       = [System.Drawing.Color]::FromArgb(255, 75,  75)
$warnSoft   = [System.Drawing.Color]::FromArgb(255, 160, 50)
$ok         = [System.Drawing.Color]::FromArgb(35,  205, 120)
$dimText    = [System.Drawing.Color]::FromArgb(80,  110, 160)
$white      = [System.Drawing.Color]::FromArgb(210, 228, 255)
$sectionBg  = [System.Drawing.Color]::FromArgb(9,   15,  30)

$form = New-Object Windows.Forms.Form
$form.Text            = "NearScreensharing Tool"
$form.Size            = New-Object System.Drawing.Size(480, 300)
$form.MinimumSize     = New-Object System.Drawing.Size(480, 300)
$form.MaximumSize     = New-Object System.Drawing.Size(480, 300)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $bg0
$form.ForeColor       = $white
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false
$form.GetType().GetProperty("DoubleBuffered",[System.Reflection.BindingFlags]"Instance,NonPublic").SetValue($form,$true,$null)

try {
    $iconUrl    = "https://raw.githubusercontent.com/diamondclass/Near-SS/refs/heads/main/nearss.webp"
    $wc         = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent","Mozilla/5.0")
    $iconBytes  = $wc.DownloadData($iconUrl)
    $iconStream = New-Object System.IO.MemoryStream(,$iconBytes)
    $iconBitmap = New-Object System.Drawing.Bitmap($iconStream)
    $iconHandle = $iconBitmap.GetHicon()
    $form.Icon  = [System.Drawing.Icon]::FromHandle($iconHandle)
} catch {
    $form.Icon = [System.Drawing.SystemIcons]::Shield
    $iconBytes = $null
}

$form.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(22,40,80), 1)
    $g.DrawRectangle($pen, 0, 0, $form.ClientSize.Width - 1, $form.ClientSize.Height - 1)
    $pen.Dispose()
    $accentPen = New-Object System.Drawing.Pen($accent, 2)
    $g.DrawLine($accentPen, 0, $form.ClientSize.Height - 2, $form.ClientSize.Width, $form.ClientSize.Height - 2)
    $g.DrawLine($accentPen, 0, 1, $form.ClientSize.Width, 1)
    $accentPen.Dispose()
})

$lblTitle = New-Object Windows.Forms.Label
$lblTitle.Text      = "NearScreensharing"
$lblTitle.Font      = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $white
$lblTitle.BackColor = [System.Drawing.Color]::Transparent
$lblTitle.AutoSize  = $true
$lblTitle.Location  = New-Object System.Drawing.Point(0, 72)
$form.Controls.Add($lblTitle)
$lblTitle.Location = New-Object System.Drawing.Point([int](($form.ClientSize.Width - $lblTitle.Width) / 2), 72)

$lblSub = New-Object Windows.Forms.Label
$lblSub.Text      = "by diamondclass  -  Version 1.1.0"
$lblSub.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$lblSub.ForeColor = $dimText
$lblSub.BackColor = [System.Drawing.Color]::Transparent
$lblSub.AutoSize  = $true
$lblSub.Location  = New-Object System.Drawing.Point(0, 130)
$form.Controls.Add($lblSub)
$lblSub.Location = New-Object System.Drawing.Point([int](($form.ClientSize.Width - $lblSub.Width) / 2), 130)

$btnScan = New-Object Windows.Forms.Button
$btnScan.Text      = "Scan"
$btnScan.Font      = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnScan.ForeColor = $white
$btnScan.BackColor = $accent
$btnScan.FlatStyle = "Flat"
$btnScan.FlatAppearance.BorderSize = 0
$btnScan.Size      = New-Object System.Drawing.Size(140, 40)
$btnScan.Location  = New-Object System.Drawing.Point([int](($form.ClientSize.Width - 140) / 2), 185)
$btnScan.Cursor    = [System.Windows.Forms.Cursors]::Hand
$btnScan.Add_MouseEnter({ $btnScan.BackColor = $accentHi })
$btnScan.Add_MouseLeave({ $btnScan.BackColor = $accent   })
$form.Controls.Add($btnScan)

$progressBg = New-Object Windows.Forms.Panel
$progressBg.Location  = New-Object System.Drawing.Point(40, 185)
$progressBg.Size      = New-Object System.Drawing.Size(400, 8)
$progressBg.BackColor = [System.Drawing.Color]::FromArgb(16, 26, 50)
$progressBg.Visible   = $false
$form.Controls.Add($progressBg)

$progressBar = New-Object Windows.Forms.Panel
$progressBar.Location  = New-Object System.Drawing.Point(0, 0)
$progressBar.Size      = New-Object System.Drawing.Size(0, 8)
$progressBar.BackColor = $accent
$progressBg.Controls.Add($progressBar)

$progressBg.Add_Paint({
    param($s,$e)
    $pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(22,40,80),1)
    $e.Graphics.DrawRectangle($pen2, 0, 0, $progressBg.Width-1, $progressBg.Height-1)
    $pen2.Dispose()
})

$lblStep = New-Object Windows.Forms.Label
$lblStep.Text      = ""
$lblStep.Font      = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Regular)
$lblStep.ForeColor = $dimText
$lblStep.BackColor = [System.Drawing.Color]::Transparent
$lblStep.AutoSize  = $false
$lblStep.Size      = New-Object System.Drawing.Size(400, 18)
$lblStep.Location  = New-Object System.Drawing.Point(40, 200)
$lblStep.TextAlign = "MiddleCenter"
$lblStep.Visible   = $false
$form.Controls.Add($lblStep)

$lblPct = New-Object Windows.Forms.Label
$lblPct.Text      = ""
$lblPct.Font      = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$lblPct.ForeColor = $accentHi
$lblPct.BackColor = [System.Drawing.Color]::Transparent
$lblPct.AutoSize  = $false
$lblPct.Size      = New-Object System.Drawing.Size(400, 16)
$lblPct.Location  = New-Object System.Drawing.Point(40, 165)
$lblPct.TextAlign = "MiddleCenter"
$lblPct.Visible   = $false
$form.Controls.Add($lblPct)

$panelDone = New-Object Windows.Forms.Panel
$panelDone.Location  = New-Object System.Drawing.Point(0, 130)
$panelDone.Size      = New-Object System.Drawing.Size(480, 130)
$panelDone.BackColor = [System.Drawing.Color]::Transparent
$panelDone.Visible   = $false
$form.Controls.Add($panelDone)

$lblDoneIcon = New-Object Windows.Forms.Label
$lblDoneIcon.Text      = "[OK]"
$lblDoneIcon.Font      = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$lblDoneIcon.ForeColor = $ok
$lblDoneIcon.BackColor = [System.Drawing.Color]::Transparent
$lblDoneIcon.AutoSize  = $true
$lblDoneIcon.Location  = New-Object System.Drawing.Point(0, 0)
$panelDone.Controls.Add($lblDoneIcon)
$lblDoneIcon.Location = New-Object System.Drawing.Point([int](($panelDone.Width - $lblDoneIcon.Width) / 2), 0)

$lblDoneMsg = New-Object Windows.Forms.Label
$lblDoneMsg.Text      = ""
$lblDoneMsg.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$lblDoneMsg.ForeColor = $dimText
$lblDoneMsg.BackColor = [System.Drawing.Color]::Transparent
$lblDoneMsg.AutoSize  = $false
$lblDoneMsg.Size      = New-Object System.Drawing.Size(440, 32)
$lblDoneMsg.Location  = New-Object System.Drawing.Point(20, 36)
$lblDoneMsg.TextAlign = "MiddleCenter"
$panelDone.Controls.Add($lblDoneMsg)

$btnOpenFolder = New-Object Windows.Forms.Button
$btnOpenFolder.Text      = "Abrir en Explorer"
$btnOpenFolder.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnOpenFolder.ForeColor = $white
$btnOpenFolder.BackColor = [System.Drawing.Color]::FromArgb(14, 50, 100)
$btnOpenFolder.FlatStyle = "Flat"
$btnOpenFolder.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(30, 80, 160)
$btnOpenFolder.FlatAppearance.BorderSize  = 1
$btnOpenFolder.Size      = New-Object System.Drawing.Size(170, 34)
$btnOpenFolder.Location  = New-Object System.Drawing.Point(50, 76)
$btnOpenFolder.Cursor    = [System.Windows.Forms.Cursors]::Hand
$btnOpenFolder.Add_MouseEnter({ $btnOpenFolder.BackColor = [System.Drawing.Color]::FromArgb(20,70,140) })
$btnOpenFolder.Add_MouseLeave({ $btnOpenFolder.BackColor = [System.Drawing.Color]::FromArgb(14,50,100) })
$panelDone.Controls.Add($btnOpenFolder)

$btnSSTool = New-Object Windows.Forms.Button
$btnSSTool.Text      = "SS Alliance Tool"
$btnSSTool.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnSSTool.ForeColor = $white
$btnSSTool.BackColor = [System.Drawing.Color]::FromArgb(16, 65, 145)
$btnSSTool.FlatStyle = "Flat"
$btnSSTool.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(30, 100, 200)
$btnSSTool.FlatAppearance.BorderSize  = 1
$btnSSTool.Size      = New-Object System.Drawing.Size(170, 34)
$btnSSTool.Location  = New-Object System.Drawing.Point(260, 76)
$btnSSTool.Cursor    = [System.Windows.Forms.Cursors]::Hand
$btnSSTool.Add_MouseEnter({ $btnSSTool.BackColor = [System.Drawing.Color]::FromArgb(25, 90, 190) })
$btnSSTool.Add_MouseLeave({ $btnSSTool.BackColor = [System.Drawing.Color]::FromArgb(16, 65, 145) })
$panelDone.Controls.Add($btnSSTool)

$script:scanLog        = New-Object System.Text.StringBuilder
$script:reportPath     = ""
$script:totalSteps     = 25
$script:step           = 0
$script:mcInfoGlobal   = @{ running=$false; version="Unknown"; client="Unknown"; memory=""; threads=0; startTime=""; jvmArgs=""; mods=@() }
$script:moduleResults  = @{}

function Add-ModuleData($key, $type, $msg, $label="") {
    if (-not $script:moduleResults.ContainsKey($key)) { $script:moduleResults[$key] = [System.Collections.Generic.List[object]]::new() }
    $script:moduleResults[$key].Add([pscustomobject]@{type=$type; msg=$msg; label=$label})
}

function Write-Out($text, $color)   { [void]$script:scanLog.Append($text) }
function Write-Header($title)       { Write-Out "`n  +---------------------------------------------------------------+`n" $null; Write-Out "  |  $($title.PadRight(62))|`n" $null; Write-Out "  +---------------------------------------------------------------+`n" $null }
function Write-Ok($text)            { Write-Out "    [OK]   $text`n" $null }
function Write-Warn($text)          { Write-Out "    [WARN] $text`n" $null }
function Write-Alert($text)         { Write-Out "    [HIT]  $text`n" $null }
function Write-Info($label,$value)  { Write-Out "    $($label.PadRight(24))$value`n" $null }
function Get-StatusString($flag)    { if ($flag) { return "warn" } else { return "ok" } }
function Set-ModuleStatus($key,$state) {}

function Get-PSHistoryScan {
    $historyFile = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyFile) {
        $commands = Get-Content $historyFile -Tail 100
        $commands | Out-File "$env:TEMP\pshistory_debug.txt"
        foreach ($cmd in $commands) {
            $trimmed = $cmd.Trim()
            if ($trimmed) { Add-ModuleData "pshistory" "info" $trimmed "Command" }
        }
        return $true
    }
    return $false
}

function Get-VMDetection {
    $vmVendors = @("vmware","virtualbox","vbox","qemu","xen","hyper-v","hyperv","parallels","innotek","bochs","kvm","bhyve","microsoft hv","virtio")
    $cs        = Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue
    $bios      = Get-WmiObject Win32_BIOS -ErrorAction SilentlyContinue
    $board     = Get-WmiObject Win32_BaseBoard -ErrorAction SilentlyContinue
    $gpu       = Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue
    $fields = @(
        if ($cs)    { $cs.Manufacturer;    $cs.Model }
        if ($bios)  { $bios.Manufacturer;  $bios.SMBIOSBIOSVersion; $bios.Version }
        if ($board) { $board.Manufacturer; $board.Product }
        if ($gpu)   { foreach ($g in $gpu) { $g.Name; $g.AdapterCompatibility } }
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $seen    = @{}
    $vmFound = $false
    foreach ($field in $fields) {
        $lower = $field.ToLower()
        foreach ($kw in $vmVendors) {
            if ($lower -match $kw -and -not $seen.ContainsKey($field)) {
                $seen[$field] = $true
                Add-ModuleData "vm" "hit" "VM indicator detected: $field"
                $vmFound = $true
            }
        }
    }
    $vmRegKeys = @(
        "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools",
        "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions",
        "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters",
        "HKLM:\SYSTEM\CurrentControlSet\Services\VBoxGuest",
        "HKLM:\SYSTEM\CurrentControlSet\Services\vmhgfs"
    )
    foreach ($key in $vmRegKeys) {
        if (Test-Path $key -ErrorAction SilentlyContinue) {
            Add-ModuleData "vm" "hit" "VM registry key present: $key"
            $vmFound = $true
        }
    }
    $vmProcs = @("vmtoolsd","vmwaretray","vmwareuser","vboxservice","vboxtray","vmsrvc","vmusrvc","vmacthlp")
    $active  = Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | ForEach-Object { $_.ToLower() }
    foreach ($vp in $vmProcs) {
        if ($active -contains $vp) {
            Add-ModuleData "vm" "hit" "VM process running: $vp"
            $vmFound = $true
        }
    }
    if (-not $vmFound) { Add-ModuleData "vm" "ok" "No VM indicators detected." }
    return $vmFound
}

function Get-MouseInfo {
    $found = $false
    try {
        $devices = Get-WmiObject Win32_PointingDevice -ErrorAction Stop | Where-Object { $_.Name -notmatch "(?i)virtual|remote|touchpad|trackpad|vmware|vbox" }
        foreach ($d in $devices) {
            $hwid  = $d.PNPDeviceID
            $brand = "Unknown"
            if ($hwid -match "VID_([0-9A-Fa-f]{4})") {
                $vid   = $matches[1].ToUpper()
                $brand = switch ($vid) {
                    "046D" { "Logitech" }
                    "1532" { "Razer" }
                    "1038" { "SteelSeries" }
                    "04F2" { "SteelSeries" }
                    "1B1C" { "Corsair" }
                    "04B4" { "Corsair" }
                    "258A" { "SinoWealth / Redragon" }
                    "1BCF" { "Marvo / PixArt OEM" }
                    "0458" { "KYE / Genius" }
                    "0E8F" { "GreenAsia / Newmen" }
                    "093A" { "PixArt" }
                    "25A7" { "Areson / Fude&Hope" }
                    "18F8" { "Holtek" }
                    "04D9" { "Holtek / Rapoo" }
                    "045E" { "Microsoft" }
                    "0C45" { "Microdia" }
                    "1D57" { "Xenta / Unifying" }
                    "16C0" { "Van Ooijen (custom/DIY)" }
                    "0B05" { "ASUS / ROG" }
                    "3367" { "Thermaltake / Tt eSports" }
                    "2516" { "Cooler Master" }
                    "0461" { "Primax Electronics" }
                    "1A2C" { "China Industry Support" }
                    "24AE" { "Shenzhen Rapoo" }
                    "248A" { "Maxxter / Gembird" }
                    "1C4F" { "SiGma Micro" }
                    "15D9" { "Trust International" }
                    "0E6A" { "Megawin / Alienware OEM" }
                    "04CA" { "Lite-On" }
                    "17EF" { "Lenovo" }
                    "04F3" { "Elan Microelectronics" }
                    "10C4" { "Silicon Labs" }
                    "0416" { "Winbond" }
                    "3938" { "MOSART Semiconductor" }
                    "0557" { "ATEN" }
                    "0A5C" { "Broadcom" }
                    "2B89" { "KFA2 / Galax" }
                    "0D9F" { "Compucase / CM Storm" }
                    "256F" { "3Dconnexion" }
                    "1D5C" { "Fresco Logic" }
                    "0BDA" { "Realtek" }
                    "046E" { "Behavior Tech (BTC)" }
                    "04E8" { "Samsung" }
                    "0CF3" { "Qualcomm Atheros" }
                    "2B2F" { "A4Tech" }
                    "09DA" { "A4Tech" }
                    default { "VID:$vid" }
                }
            }
            $pid_str = ""
            if ($hwid -match "PID_([0-9A-Fa-f]{4})") { $pid_str = $matches[1].ToUpper() }
            $display = if ($pid_str) { "$($d.Name)  [$brand | PID:$pid_str]" } else { "$($d.Name)  [$brand]" }
            Add-ModuleData "mouse" "info" $display "WMI"
            $found = $true
        }
    } catch {}

    if (-not $found) {
        try {
            $pnp = Get-PnpDevice -Class Mouse -Status OK -ErrorAction Stop | Where-Object { $_.FriendlyName -notmatch "(?i)virtual|HID-compliant|remote|vbox|vmware" }
            foreach ($p in $pnp) {
                Add-ModuleData "mouse" "info" $p.FriendlyName "PnP"
                $found = $true
            }
        } catch {}
    }

    if (-not $found) {
        try {
            $hidPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\HID"
            Get-ChildItem $hidPath -ErrorAction SilentlyContinue | ForEach-Object {
                Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                    $devInfo = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
                    if ($devInfo -and $devInfo.DeviceDesc -match "(?i)mouse|pointer|pointing") {
                        $desc = ($devInfo.DeviceDesc -split ";")[-1].Trim()
                        Add-ModuleData "mouse" "info" $desc "HID Registry"
                        $found = $true
                    }
                }
            }
        } catch {}
    }

    if (-not $found) { Add-ModuleData "mouse" "warn" "No physical mouse detected or info unavailable." }
    return $found
}

function Get-BootTime {
    $result = $null
    try {
        $logonEvent = Get-WinEvent -FilterHashtable @{ LogName='Winlogon'; Id=6003 } -MaxEvents 100 -ErrorAction Stop | Where-Object { $_.Properties.Count -gt 8 -and ($_.Properties[8].Value -eq 2 -or $_.Properties[8].Value -eq 10 -or $_.Properties[8].Value -eq 11) } | Where-Object { $_.Properties.Count -gt 5 -and $_.Properties[5].Value -eq [System.Environment]::UserName } | Sort-Object TimeCreated -Descending | Select-Object -First 1
        if ($logonEvent) { $result = $logonEvent.TimeCreated }
    } catch {}
    if ($result -eq $null) {
        try { $os = Get-WmiObject Win32_OperatingSystem -ErrorAction Stop; $result = $os.ConvertToDateTime($os.LastBootUpTime) } catch {}
    }
    if ($result -eq $null) { $result = (Get-Date).AddHours(-8) }
    return $result
}

function Get-BrowserHistoryScan {
    param($bootTime)
    $historyFound = $false
    $keywords = @(
        "vape\.gg", "drip\.gg", "slinky\.gg", "doomsdayclient\.com",
        "rusherhack\.org", "sigma-client\.com", "inertiaclient\.com",
        "meteorclient\.com", "liquidbounce\.net", "aristois\.net",
        "zeroday\.gg", "autoclicker\.io", "stringcleaner\.xyz","gayporn\.xxx"
    )
    $browsers = @(
        @{ name="Chrome";    path="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History";               tmp="$env:TEMP\nss_ch_hist"   },
        @{ name="Chrome P1"; path="$env:LOCALAPPDATA\Google\Chrome\User Data\Profile 1\History";             tmp="$env:TEMP\nss_ch_p1"     },
        @{ name="Edge";      path="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History";              tmp="$env:TEMP\nss_edge_hist"  },
        @{ name="Brave";     path="$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\History"; tmp="$env:TEMP\nss_brave_hist" },
        @{ name="Firefox";   path="";                                                                        tmp="$env:TEMP\nss_ff_hist"   }
    )
    $ffBase = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $ffBase) {
        $ffProfile = Get-ChildItem $ffBase -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($ffProfile) { $browsers[4].path = "$($ffProfile.FullName)\places.sqlite" }
    }
    foreach ($browser in $browsers) {
        if ([string]::IsNullOrEmpty($browser.path) -or -not (Test-Path $browser.path)) { continue }
        try {
            Copy-Item $browser.path -Destination $browser.tmp -Force -ErrorAction SilentlyContinue
            $bytes = [System.IO.File]::ReadAllBytes($browser.tmp)
            $text  = [System.Text.Encoding]::UTF8.GetString($bytes)
            if ($text) {
                foreach ($kw in $keywords) {
                    if ($text -match $kw) {
                        $matched = $kw -replace '\\',''
                        Add-ModuleData "browser" "hit" "[$($browser.name)] Visited: $matched"
                        $historyFound = $true
                    }
                }
            }
            Remove-Item $browser.tmp -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    return $historyFound
}

function Get-JavawMemoryScan {
    param($pIDProcess)
    $memFound = $false
    $targets = @("vape.gg","drip.gg","aimassist","killaura","slinky","exodus.codes","jnativehook",
                 "string cleaner","sparkcrack","striker","monolith","lithiumclient","dream-injector",
                 "unicorn client","uwu client","sapphire","vape launcher","pe injector",
                 "cracked by kangaroo")
    if (-not $pIDProcess) { return $false }
    try {
        $wmiMem = Get-WmiObject Win32_Process -Filter "ProcessId = $pIDProcess" -ErrorAction Stop
        if ($wmiMem -and $wmiMem.CommandLine) {
            $memStrings = $wmiMem.CommandLine
            foreach ($t in $targets) { if ($memStrings -match $t) { Write-Alert "Memory/Heap String found: $t"; $memFound = $true } }
        }
    } catch {}
    return $memFound
}

function Get-MinecraftInfo {
    param($pIDProcess)
    $info = @{
        running=$false; version="Unknown"; client="Vanilla";
        jvmArgs=""; cmdLine=""; mods=@(); pid=$pIDProcess;
        startTime=""; memory=""; threads=0
    }
    if (-not $pIDProcess) { return $info }
    try {
        $proc = Get-Process -Id $pIDProcess -ErrorAction Stop
        $info.running   = $true
        $info.startTime = $proc.StartTime.ToString('yyyy-MM-dd HH:mm:ss')
        $info.memory    = "$([Math]::Round($proc.WorkingSet64/1MB,1)) MB"
        $info.threads   = $proc.Threads.Count
        $winTitle = $proc.MainWindowTitle
        $wmiMC = Get-WmiObject Win32_Process -Filter "ProcessId = $pIDProcess" -ErrorAction Stop
        if ($wmiMC -and $wmiMC.CommandLine) {
            $cmd = $wmiMC.CommandLine
            $info.cmdLine = $cmd
            if ($cmd -match "lunar" -or $winTitle -match "Lunar") {
                $info.client = "Lunar Client"
                if ($cmd -match "--version\s+([\d\.]+)") { $info.version = $matches[1] }
            } elseif ($cmd -match "badlion" -or $winTitle -match "Badlion") {
                $info.client = "Badlion Client"
                if ($cmd -match "version\s+([\d\.]+)") { $info.version = $matches[1] }
            } elseif ($cmd -match "salwyrr" -or $winTitle -match "Salwyrr") {
                $info.client = "Salwyrr Launcher"
            } elseif ($cmd -match "feather" -or $winTitle -match "Feather") {
                $info.client = "Feather Client"
            } elseif ($cmd -match "labymod" -or $winTitle -match "LabyMod") {
                $info.client = "LabyMod"
            } elseif ($cmd -match "forge") {
                $info.client = "Minecraft Forge"
            } elseif ($cmd -match "fabric") {
                $info.client = "Fabric"
            }
            if ($info.version -eq "Unknown") {
                $verMatch = [regex]::Match($cmd, '(?i)[\\/]versions[\\/]([\d\.]+)')
                if ($verMatch.Success) {
                    $info.version = $verMatch.Groups[1].Value
                } elseif ($winTitle -match "1\.8\.\d+|1\.7\.\d+|1\.1[2-9]\.\d+|1\.2[0-9]\.\d+") {
                    $info.version = $matches[0]
                } elseif ($cmd -match "-Dminecraft\.version=([\d\.]+)") {
                    $info.version = $matches[1]
                }
            }
            $modMatches = [regex]::Matches($cmd, 'mods[\\/]([^\\/\s"]+\.jar)')
            foreach ($m in $modMatches) { $info.mods += $m.Groups[1].Value }
            $xmxMatch = [regex]::Match($cmd, '-Xmx(\d+[gGmM])')
            if ($xmxMatch.Success) { $info.jvmArgs = "-Xmx$($xmxMatch.Groups[1].Value)" }
        }
    } catch {
        $info.running = $false
    }
    return $info
}

$win32Code = @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left; public int Top; public int Right; public int Bottom;
    }
}
"@
if (-not ([System.Management.Automation.PSTypeName]"Win32").Type) {
    Add-Type -TypeDefinition $win32Code -ReferencedAssemblies "System.Drawing"
}

function Take-Screenshot {
    param([int]$pIDProcess = 0)
    try {
        $handle = [IntPtr]::Zero
        $javaProcesses = Get-Process -Name "javaw" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }
        if ($javaProcesses) {
            $targetProc = $javaProcesses | Where-Object { $_.Id -eq $pIDProcess } | Select-Object -First 1
            if (-not $targetProc) { $targetProc = $javaProcesses | Select-Object -First 1 }
            $handle = $targetProc.MainWindowHandle
        }
        if ($handle -eq [IntPtr]::Zero -and $pIDProcess -gt 0) {
            $procById = Get-Process -Id $pIDProcess -ErrorAction SilentlyContinue
            if ($procById) { $handle = $procById.MainWindowHandle }
        }
        if ($handle -eq [IntPtr]::Zero) { $handle = [Win32]::GetForegroundWindow() }
        $rect = New-Object Win32+RECT
        if ($handle -ne [IntPtr]::Zero -and [Win32]::GetWindowRect($handle, [ref]$rect)) {
            $width  = $rect.Right - $rect.Left
            $height = $rect.Bottom - $rect.Top
            if ($width -gt 200 -and $height -gt 200) {
                $bmp = New-Object System.Drawing.Bitmap($width, $height)
                $g   = [System.Drawing.Graphics]::FromImage($bmp)
                $g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bmp.Size)
                $g.Dispose()
            }
        }
        if ($null -eq $bmp) {
            $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
            $bmp = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
            $g   = [System.Drawing.Graphics]::FromImage($bmp)
            $g.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
            $g.Dispose()
        }
        $ms = New-Object System.IO.MemoryStream
        $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $bytes = $ms.ToArray()
        $ms.Dispose(); $bmp.Dispose()
        return [Convert]::ToBase64String($bytes)
    } catch { return "" }
}

function Export-HtmlReport {
    param($findings, $elapsed, $bootTime, $mcInfo, $screenshotB64)

    $scanUser   = [System.Environment]::UserName
    $scanHost   = $env:COMPUTERNAME
    $scanDate   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logonStr   = if ($bootTime) { $bootTime.ToString('yyyy-MM-dd HH:mm:ss') } else { "Unknown" }
    $durVal     = "$([Math]::Round($elapsed,1))s"
    $badgeColor = if ($findings -gt 0) { "#ff4040" } else { "#1ec870" }
    $badgeText  = if ($findings -gt 0) { "$findings FINDING(S) - REVIEW REQUIRED" } else { "CLEAN - NO SUSPICIOUS FINDINGS" }

    $safeclients   = @("Vanilla","Minecraft Forge","Fabric","Quilt","NeoForge","OptiFine","Unknown","N/A")
    $legalClients  = @("Lunar Client","Badlion Client","Feather Client","LabyMod","Salwyrr Launcher","Prism Launcher","MultiMC","PolyMC","ATLauncher")
    $mcClientColor = if ($safeclients -contains $mcInfo.client -or $legalClients -contains $mcInfo.client) { "#4a9bff" } elseif ($mcInfo.client -ne "Unknown") { "#ff4040" } else { "#4a9bff" }
    $mcDotColor    = if ($mcInfo.running) { "#1ec870" } else { "#ff9820" }
    $mcStatusText  = if ($mcInfo.running) { "Running" } else { "Not Detected" }
    $mcVersion     = [System.Net.WebUtility]::HtmlEncode($mcInfo.version)
    $mcClient      = [System.Net.WebUtility]::HtmlEncode($mcInfo.client)
    $mcMemory      = [System.Net.WebUtility]::HtmlEncode($mcInfo.memory)
    $mcThreads     = $mcInfo.threads
    $mcStart       = [System.Net.WebUtility]::HtmlEncode($mcInfo.startTime)
    $mcJvm         = [System.Net.WebUtility]::HtmlEncode($mcInfo.jvmArgs)
    $modTagsHtml   = ""
    foreach ($mod in $mcInfo.mods) { $modTagsHtml += "<span class=`"tag`">" + [System.Net.WebUtility]::HtmlEncode($mod) + "</span>" }
    $modsRow = if ($modTagsHtml) { "<div class=`"mods-lbl`">Detected JARs / Mods</div><div class=`"tags`">$modTagsHtml</div>" } else { "" }

    $ssHtml = ""
    if ($screenshotB64 -and $screenshotB64.Length -gt 100) {
        $ssHtml = "<section id=`"screenshot`"><h2 class=`"sec-h`">Screen Capture</h2><div class=`"ss-wrap`"><img src=`"data:image/jpeg;base64,$screenshotB64`" class=`"ss-img`" /></div></section>"
    }

    $moduleIds = @(
        @{id="s01";title="Services"},
        @{id="s02";title="DNS Cache"},
        @{id="s03";title="USB History"},
        @{id="s04";title="BAM Logs"},
        @{id="s05";title="Hosts File"},
        @{id="s06";title="Suspicious Apps"},
        @{id="s07";title="Prefetch"},
        @{id="s08";title="Recording Software"},
        @{id="s09";title="Mod Times"},
        @{id="s10";title="JNativeHook"},
        @{id="s11";title="Exec + Deleted"},
        @{id="s12";title="Minecraft"},
        @{id="s13";title="In-Instance"},
        @{id="s14";title="Out-of-Instance"},
        @{id="s15";title="Startup"},
        @{id="s16";title="Alt Accounts"},
        @{id="s17";title="AnyDesk"},
        @{id="s18";title="Browser History"},
        @{id="s19";title="Heap Strings"},
        @{id="s20";title="VM Detection"},
        @{id="s21";title="Mouse Device"},
        @{id="s22";title="Shell:Recent"},
        @{id="s23";title="PS Command History"},
        @{id="s24";title="DisallowRun"},
        @{id="s25";title="Deleted BAM Keys"}
    )

    $moduleKeys = @(
        "services","dns","usb","bam","hosts","apps","prefetch","recording",
        "modtimes","jnative","execdel","minecraft","ininst","outinst",
        "startup","alts","anydesk","browser","heap","vm","mouse","recent","pshistory","disallowrun","delbam"
    )

    $cardsHtml    = ""
    $sidebarLinks = ""
    $displayNum   = 1

    for ($i = 0; $i -lt $moduleIds.Count; $i++) {
        $mod   = $moduleIds[$i]
        $key   = $moduleKeys[$i]
        $items = if ($script:moduleResults.ContainsKey($key)) { $script:moduleResults[$key] } else { @() }

        $hasHit  = $items | Where-Object { $_.type -eq "hit" }
        $hasWarn = $items | Where-Object { $_.type -eq "warn" }

        if (-not $hasHit -and -not $hasWarn -and $key -ne "minecraft" -and $key -ne "pshistory" -and $key -ne "recent") {
            continue
        }

        if ($hasHit)      { $sc="#ff4040"; $sl="HIT";  $sbClass="hit"  }
        elseif ($hasWarn) { $sc="#ff9820"; $sl="WARN"; $sbClass="warn" }
        else              { $sc="#1ec870"; $sl="OK";   $sbClass="ok"   }

        $numStr = $displayNum.ToString("D2")
        $rowsHtml = ""
        
        if ($items.Count -eq 0) {
            $rowsHtml = "<div class=`"row row-ok`"><span class=`"pill pill-ok`">OK</span><span class=`"row-msg`">No findings.</span></div>"
        } else {
            foreach ($item in $items) {
                $msg = [System.Net.WebUtility]::HtmlEncode($item.msg)
                if ($item.type -eq "hit") {
                    $rowsHtml += "<div class=`"row row-hit`"><span class=`"pill pill-hit`">HIT</span><span class=`"row-msg`">$msg</span></div>"
                } elseif ($item.type -eq "warn") {
                    $rowsHtml += "<div class=`"row row-warn`"><span class=`"pill pill-warn`">WARN</span><span class=`"row-msg`">$msg</span></div>"
                } elseif ($item.type -eq "ok") {
                    $rowsHtml += "<div class=`"row row-ok`"><span class=`"pill pill-ok`">OK</span><span class=`"row-msg`">$msg</span></div>"
                } elseif ($item.type -eq "info") {
                    $lbl = [System.Net.WebUtility]::HtmlEncode($item.label)
                    $rowsHtml += "<div class=`"row row-info`"><span class=`"row-lbl`">$lbl</span><span class=`"row-val`">$msg</span></div>"
                }
            }
        }

        $isExpandable = ($key -eq "recent" -or $key -eq "pshistory")

        if ($isExpandable) {
            $entryCount  = $items.Count
            $countLabel  = if ($entryCount -eq 1) { "1 entrada" } else { "$entryCount entradas" }
            $placeholder = "<div class=`"expand-placeholder`"><div class=`"expand-placeholder-info`"><span class=`"expand-placeholder-count`">$countLabel</span><span class=`"expand-placeholder-hint`">Contenido oculto por privacidad</span></div><button class=`"expand-btn`" onclick=`"openModal('$($mod.id)','$($mod.title)')`">Mostrar completo</button></div>"
            $cardsHtml += "<div class=`"mod-card expandable`" id=`"$($mod.id)`"><div class=`"mod-hdr`"><span class=`"mod-num`">$numStr</span><span class=`"mod-title`">$($mod.title)</span><span class=`"mod-badge`" style=`"color:$sc;border-color:${sc}30;background:${sc}10`">$sl</span></div><div class=`"mod-body-hidden`" aria-hidden=`"true`">$rowsHtml</div>$placeholder</div>`n"
        } else {
            $cardsHtml += "<div class=`"mod-card`" id=`"$($mod.id)`"><div class=`"mod-hdr`"><span class=`"mod-num`">$numStr</span><span class=`"mod-title`">$($mod.title)</span><span class=`"mod-badge`" style=`"color:$sc;border-color:${sc}30;background:${sc}10`">$sl</span></div><div class=`"mod-body`">$rowsHtml</div></div>`n"
        }
        $sidebarLinks += "<a class=`"sb-link $sbClass`" onclick=`"scrollTo('$($mod.id)')`"><div class=`"sb-num`">$numStr</div>$($mod.title)</a>`n"
        
        $displayNum++
    }

    return @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>NSS Report - $scanDate</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
:root{
  --bg:#06070d;--bg1:#090d18;--bg2:#0c1122;--bg3:#111828;
  --accent:#1e6fff;--accent-hi:#4a9bff;
  --warn:#ff4040;--warn-s:#ff9820;--ok:#1ec870;
  --dim:#3a4d68;--dim2:#566880;--white:#c8dcff;
  --border:#0d1828;--card:#08111f;--card2:#0a1428;
}
html,body{background:var(--bg);color:var(--white);font-family:'Inter',sans-serif;height:100%;overflow:hidden;}
body{display:flex;flex-direction:column;}
.topbar{flex-shrink:0;background:linear-gradient(90deg,#0a1020,#06070d);border-bottom:2px solid var(--accent);padding:0 28px;height:54px;display:flex;align-items:center;gap:16px;}
.tb-logo{font-size:16px;font-weight:700;color:var(--white);}
.tb-logo span{color:var(--accent-hi);}
.tb-sub{font-size:10px;color:var(--dim2);margin-top:1px;}
.tb-badge{margin-left:auto;display:flex;align-items:center;gap:8px;padding:6px 16px;border-radius:20px;font-size:11px;font-weight:600;border:1px solid;letter-spacing:.3px;}
.tb-dot{width:6px;height:6px;border-radius:50%;}
.main{display:flex;flex:1;overflow:hidden;}
.sidebar{width:195px;flex-shrink:0;background:var(--bg1);border-right:1px solid var(--border);display:flex;flex-direction:column;overflow-y:auto;}
.sb-head{padding:14px 14px 6px;font-size:9px;font-weight:700;color:var(--dim);letter-spacing:1.8px;text-transform:uppercase;}
.sb-link{display:flex;align-items:center;gap:9px;padding:7px 12px;font-size:11.5px;color:var(--dim2);cursor:pointer;border-left:2px solid transparent;transition:all .12s;user-select:none;}
.sb-link:hover{background:rgba(30,111,255,.07);color:var(--white);border-left-color:rgba(30,111,255,.4);}
.sb-link.active{background:rgba(30,111,255,.11);color:var(--white);border-left-color:var(--accent);}
.sb-link.hit  .sb-num{background:rgba(255,64,64,.2);color:#ff6060;}
.sb-link.warn .sb-num{background:rgba(255,152,32,.15);color:#ffa040;}
.sb-link.ok   .sb-num{background:rgba(30,200,112,.1);color:#1ec870;}
.sb-link.hit{color:var(--white);}
.sb-num{width:24px;height:18px;border-radius:4px;background:var(--bg2);font-size:9px;font-weight:700;color:var(--dim);display:flex;align-items:center;justify-content:center;flex-shrink:0;font-family:'JetBrains Mono',monospace;}
.sb-meta{margin-top:auto;border-top:1px solid var(--border);padding:12px 14px 16px;}
.sb-mr{font-size:10px;color:var(--dim2);line-height:1.9;font-family:'JetBrains Mono',monospace;}
.sb-mr b{color:var(--white);font-weight:500;}
.content{flex:1;overflow-y:auto;padding:26px 30px 60px;}
.hero{background:linear-gradient(135deg,#0b1222,#07080e);border:1px solid var(--border);border-top:3px solid var(--accent);border-radius:12px;padding:24px 26px;margin-bottom:26px;position:relative;overflow:hidden;}
.hero::after{content:'';position:absolute;top:0;right:0;width:260px;height:100%;background:radial-gradient(ellipse at right,rgba(30,111,255,.08),transparent 70%);pointer-events:none;}
.hero-title{font-size:20px;font-weight:700;margin-bottom:2px;}
.hero-title span{color:var(--accent-hi);}
.hero-sub{font-size:11px;color:var(--dim2);margin-bottom:18px;}
.meta-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:9px;margin-bottom:18px;}
.meta-cell{background:rgba(30,111,255,.05);border:1px solid rgba(30,111,255,.11);border-radius:7px;padding:10px 12px;}
.meta-l{font-size:9px;font-weight:600;color:var(--dim2);letter-spacing:1px;text-transform:uppercase;margin-bottom:3px;}
.meta-v{font-size:11px;font-weight:500;color:var(--white);font-family:'JetBrains Mono',monospace;word-break:break-all;}
.hero-badge{display:inline-flex;align-items:center;gap:8px;border:1px solid;border-radius:8px;padding:8px 16px;font-size:12px;font-weight:600;}
.hero-bdot{width:7px;height:7px;border-radius:50%;}
.sec-h{font-size:10px;font-weight:700;color:var(--dim2);letter-spacing:1.8px;text-transform:uppercase;margin:26px 0 13px;display:flex;align-items:center;gap:10px;}
.sec-h::after{content:'';flex:1;height:1px;background:var(--border);}
.mc-card{background:var(--card);border:1px solid var(--border);border-radius:10px;padding:18px 20px;margin-bottom:8px;}
.mc-sr{display:flex;align-items:center;gap:8px;margin-bottom:14px;}
.mc-dot{width:8px;height:8px;border-radius:50%;}
.mc-sl{font-size:12px;font-weight:600;}
.mc-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:12px;}
.mc-cell{background:rgba(30,111,255,.04);border:1px solid rgba(30,111,255,.09);border-radius:6px;padding:8px 10px;}
.mc-cl{font-size:9px;font-weight:600;color:var(--dim2);letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;}
.mc-cv{font-size:11px;font-weight:500;color:var(--white);font-family:'JetBrains Mono',monospace;}
.mods-lbl{font-size:9px;font-weight:600;color:var(--dim2);letter-spacing:1px;text-transform:uppercase;margin-bottom:6px;}
.tags{display:flex;flex-wrap:wrap;gap:5px;}
.tag{background:rgba(30,111,255,.1);border:1px solid rgba(30,111,255,.22);border-radius:4px;padding:2px 7px;font-size:10px;font-family:'JetBrains Mono',monospace;color:var(--accent-hi);}
.mods-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:10px;}
.mod-card{background:var(--card);border:1px solid var(--border);border-radius:9px;overflow:hidden;}
.mod-hdr{display:flex;align-items:center;gap:10px;padding:10px 14px;background:var(--card2);border-bottom:1px solid var(--border);}
.mod-num{width:26px;height:18px;background:var(--bg2);border-radius:4px;font-size:9px;font-weight:700;color:var(--dim);display:flex;align-items:center;justify-content:center;flex-shrink:0;font-family:'JetBrains Mono',monospace;}
.mod-title{font-size:12px;font-weight:600;color:var(--white);flex:1;}
.mod-badge{font-size:9px;font-weight:700;letter-spacing:.6px;padding:2px 8px;border-radius:10px;border:1px solid;}
.mod-body{padding:10px 14px;display:flex;flex-direction:column;gap:3px;}
.row{display:flex;align-items:flex-start;gap:9px;padding:5px 0;border-top:1px solid rgba(13,24,40,.8);}
.row:first-child{border-top:none;}
.pill{flex-shrink:0;font-size:9px;font-weight:700;letter-spacing:.5px;padding:2px 6px;border-radius:4px;margin-top:1px;}
.pill-hit{background:rgba(255,64,64,.15);color:#ff6060;}
.pill-warn{background:rgba(255,152,32,.12);color:#ffa040;}
.pill-ok{background:rgba(30,200,112,.1);color:#1ec870;}
.row-msg{font-size:11.5px;color:var(--white);word-break:break-word;line-height:1.5;}
.row-hit .row-msg{color:#ffb0b0;}
.row-warn .row-msg{color:#ffd090;}
.row-ok .row-msg{color:var(--dim2);}
.row-lbl{flex-shrink:0;width:130px;font-size:10.5px;color:var(--dim2);font-family:'JetBrains Mono',monospace;}
.row-val{font-size:10.5px;color:var(--white);font-family:'JetBrains Mono',monospace;word-break:break-all;}
.ss-wrap{background:var(--card);border:1px solid var(--border);border-radius:10px;padding:10px;}
.ss-img{width:100%;border-radius:6px;display:block;}
.footer{flex-shrink:0;background:var(--bg1);border-top:1px solid var(--border);padding:12px 28px;display:flex;justify-content:space-between;font-size:10px;color:var(--dim);}
::-webkit-scrollbar{width:5px;}
::-webkit-scrollbar-track{background:transparent;}
::-webkit-scrollbar-thumb{background:#0d1828;border-radius:3px;}
::-webkit-scrollbar-thumb:hover{background:var(--accent);}
.mod-body-hidden{display:none;}
.mod-card.expandable .mod-hdr{cursor:default;}
.expand-placeholder{display:flex;align-items:center;justify-content:space-between;padding:12px 14px;gap:12px;}
.expand-placeholder-info{display:flex;flex-direction:column;gap:3px;}
.expand-placeholder-count{font-size:11px;font-weight:600;color:var(--white);font-family:'JetBrains Mono',monospace;}
.expand-placeholder-hint{font-size:10px;color:var(--dim2);}
.expand-btn{flex-shrink:0;background:rgba(30,111,255,.1);border:1px solid rgba(30,111,255,.3);color:var(--accent-hi);font-size:11px;font-weight:600;font-family:'Inter',sans-serif;padding:7px 16px;border-radius:7px;cursor:pointer;transition:all .15s;letter-spacing:.2px;}
.expand-btn:hover{background:rgba(30,111,255,.22);border-color:var(--accent);color:#fff;}
.modal-backdrop{position:fixed;inset:0;z-index:999;display:flex;align-items:center;justify-content:center;opacity:0;pointer-events:none;transition:opacity .2s;}
.modal-backdrop.open{opacity:1;pointer-events:all;}
.modal-blur{position:absolute;inset:0;background:rgba(4,6,14,.7);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);}
.modal-box{position:relative;z-index:1;width:min(780px,92vw);max-height:82vh;background:var(--bg1);border:1px solid rgba(30,111,255,.22);border-top:2px solid var(--accent);border-radius:14px;display:flex;flex-direction:column;box-shadow:0 32px 80px rgba(0,0,0,.7),0 0 0 1px rgba(30,111,255,.08);transform:translateY(18px) scale(.97);transition:transform .22s cubic-bezier(.22,1,.36,1);}
.modal-backdrop.open .modal-box{transform:translateY(0) scale(1);}
.modal-hdr{display:flex;align-items:center;gap:10px;padding:14px 18px;border-bottom:1px solid var(--border);flex-shrink:0;}
.modal-title{font-size:13px;font-weight:700;color:var(--white);flex:1;}
.modal-badge-wrap{display:flex;align-items:center;gap:8px;}
.modal-count{font-size:10px;color:var(--dim2);font-family:'JetBrains Mono',monospace;}
.modal-close{width:26px;height:26px;border-radius:6px;background:rgba(255,255,255,.04);border:1px solid var(--border);color:var(--dim2);font-size:14px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .12s;flex-shrink:0;}
.modal-close:hover{background:rgba(255,64,64,.12);border-color:rgba(255,64,64,.3);color:#ff6060;}
.modal-body{overflow-y:auto;padding:14px 18px 20px;display:flex;flex-direction:column;gap:3px;}
.modal-body::-webkit-scrollbar{width:4px;}
.modal-body::-webkit-scrollbar-track{background:transparent;}
.modal-body::-webkit-scrollbar-thumb{background:rgba(30,111,255,.25);border-radius:2px;}
.modal-body::-webkit-scrollbar-thumb:hover{background:var(--accent);}
.modal-search-wrap{position:relative;padding:10px 18px;border-bottom:1px solid var(--border);flex-shrink:0;}
.modal-search-icon{position:absolute;left:30px;top:50%;transform:translateY(-50%);color:var(--dim2);font-size:12px;pointer-events:none;}
.modal-search{width:100%;background:rgba(255,255,255,.04);border:1px solid rgba(30,111,255,.2);border-radius:7px;padding:7px 12px 7px 32px;color:var(--white);font-size:11.5px;font-family:'Inter',sans-serif;outline:none;transition:border-color .15s;box-sizing:border-box;}
.modal-search:focus{border-color:var(--accent);background:rgba(30,111,255,.06);}
.modal-search::placeholder{color:var(--dim2);}
.modal-no-results{padding:24px;text-align:center;color:var(--dim2);font-size:11px;font-style:italic;}
</style>
</head>
<body>
<div class="topbar">
  <div>
    <div class="tb-logo">Near<span>Screensharing</span> Tool</div>
    <div class="tb-sub">by diamondclass &mdash; Beta 0.1.0 &mdash; $scanDate</div>
  </div>
  <div class="tb-badge" style="color:$badgeColor;border-color:${badgeColor}35;background:${badgeColor}0d;">
    <div class="tb-dot" style="background:$badgeColor;box-shadow:0 0 5px ${badgeColor}80;"></div>
    $badgeText
  </div>
</div>
<div class="main">
  <nav class="sidebar">
    <div class="sb-head">Modules</div>
    $sidebarLinks
    <div class="sb-meta">
      <div class="sb-mr">User: <b>$scanUser</b></div>
      <div class="sb-mr">Host: <b>$scanHost</b></div>
      <div class="sb-mr">Logon: <b>$logonStr</b></div>
      <div class="sb-mr">Dur: <b>$durVal</b></div>
      <div class="sb-mr">Hits: <b style="color:$badgeColor;">$findings</b></div>
    </div>
  </nav>
  <main class="content" id="main-content">
    <div class="hero">
      <div class="hero-title">Near<span>Screensharing</span> Tool</div>
      <div class="hero-sub">Automated screenshare scan &mdash; $scanDate</div>
      <div class="meta-grid">
        <div class="meta-cell"><div class="meta-l">Date</div><div class="meta-v">$scanDate</div></div>
        <div class="meta-cell"><div class="meta-l">User</div><div class="meta-v">$scanUser</div></div>
        <div class="meta-cell"><div class="meta-l">Hostname</div><div class="meta-v">$scanHost</div></div>
        <div class="meta-cell"><div class="meta-l">Logon</div><div class="meta-v">$logonStr</div></div>
        <div class="meta-cell"><div class="meta-l">Duration</div><div class="meta-v">$durVal</div></div>
      </div>
      <div class="hero-badge" style="color:$badgeColor;border-color:${badgeColor}35;background:${badgeColor}0d;">
        <div class="hero-bdot" style="background:$badgeColor;box-shadow:0 0 5px ${badgeColor}90;"></div>
        $badgeText
      </div>
    </div>
    <h2 class="sec-h">Minecraft Process</h2>
    <div class="mc-card">
      <div class="mc-sr">
        <div class="mc-dot" style="background:$mcDotColor;box-shadow:0 0 5px ${mcDotColor}70;"></div>
        <span class="mc-sl" style="color:$mcDotColor;">$mcStatusText</span>
      </div>
      <div class="mc-grid">
        <div class="mc-cell"><div class="mc-cl">Version</div><div class="mc-cv">$mcVersion</div></div>
        <div class="mc-cell"><div class="mc-cl">Client</div><div class="mc-cv" style="color:$mcClientColor;">$mcClient</div></div>
        <div class="mc-cell"><div class="mc-cl">Memory</div><div class="mc-cv">$mcMemory</div></div>
        <div class="mc-cell"><div class="mc-cl">Threads</div><div class="mc-cv">$mcThreads</div></div>
        <div class="mc-cell"><div class="mc-cl">Start Time</div><div class="mc-cv">$mcStart</div></div>
        <div class="mc-cell"><div class="mc-cl">JVM Args</div><div class="mc-cv">$mcJvm</div></div>
      </div>
      $modsRow
    </div>
    $ssHtml
    <h2 class="sec-h">Scan Results</h2>
    <div class="mods-grid">
      $cardsHtml
    </div>
  </main>
</div>
<div class="footer">
  <span>NearScreensharing Tool &mdash; $scanDate &mdash; by diamondclass</span>
  <span>Confidential screenshare report</span>
</div>

<div class="modal-backdrop" id="modal-backdrop" onclick="closeModalOnBackdrop(event)">
  <div class="modal-blur"></div>
  <div class="modal-box" id="modal-box">
    <div class="modal-hdr">
      <span class="modal-title" id="modal-title"></span>
      <span class="modal-count" id="modal-count"></span>
      <button class="modal-close" onclick="closeModal()" title="Cerrar (Esc)">&#x2715;</button>
    </div>
    <div class="modal-search-wrap">
      <span class="modal-search-icon">&#x2315;</span>
      <input class="modal-search" id="modal-search" type="text" placeholder="Buscar..." oninput="filterModal(this.value)" autocomplete="off" spellcheck="false" />
    </div>
    <div class="modal-body" id="modal-body"></div>
  </div>
</div>
<script>
function scrollTo(id){
  var el=document.getElementById(id);
  var content=document.getElementById('main-content');
  if(el&&content){content.scrollTo({top:el.offsetTop-16,behavior:'smooth'});}
}
(function(){
  var content=document.getElementById('main-content');
  var cards=document.querySelectorAll('.mod-card');
  var links=document.querySelectorAll('.sb-link');
  content.addEventListener('scroll',function(){
    var top=content.scrollTop+60;
    var active=null;
    cards.forEach(function(c){if(c.offsetTop<=top)active=c.id;});
    links.forEach(function(l){
      var m=l.getAttribute('onclick').match(/'([^']+)'/);
      if(m)l.classList.toggle('active',m[1]===active);
    });
  });
})();
function openModal(id,title){
  var src=document.querySelector('#'+id+' .mod-body-hidden');
  if(!src)return;
  document.getElementById('modal-title').textContent=title;
  var allRows=src.querySelectorAll('.row');
  document.getElementById('modal-count').textContent=allRows.length+' entradas';
  var body=document.getElementById('modal-body');
  body.innerHTML=src.innerHTML;
  var search=document.getElementById('modal-search');
  search.value='';
  var backdrop=document.getElementById('modal-backdrop');
  backdrop.classList.add('open');
  document.addEventListener('keydown',handleModalKey);
  body.scrollTop=0;
  setTimeout(function(){search.focus();},220);
}
function filterModal(q){
  var body=document.getElementById('modal-body');
  var rows=body.querySelectorAll('.row');
  var term=q.trim().toLowerCase();
  var visible=0;
  rows.forEach(function(r){
    var text=r.textContent.toLowerCase();
    var match=!term||text.indexOf(term)!==-1;
    r.style.display=match?'':'none';
    if(match)visible++;
  });
  var noRes=body.querySelector('.modal-no-results');
  if(noRes)noRes.remove();
  if(term&&visible===0){
    var d=document.createElement('div');
    d.className='modal-no-results';
    d.textContent='Sin resultados para "'+q+'"';
    body.appendChild(d);
  }
  document.getElementById('modal-count').textContent=visible+' entradas'+(term?' (filtradas)':'');
}
function closeModal(){
  document.getElementById('modal-backdrop').classList.remove('open');
  document.removeEventListener('keydown',handleModalKey);
}
function closeModalOnBackdrop(e){
  if(e.target===document.getElementById('modal-backdrop')||e.target.classList.contains('modal-blur')){closeModal();}
}
function handleModalKey(e){
  if(e.key==='Escape')closeModal();
  if((e.ctrlKey||e.metaKey)&&e.key==='f'){e.preventDefault();document.getElementById('modal-search').focus();}
}
</script>
</body>
</html>
"@
}

$recordingSoftwares = @{
    "obs"="OBS Studio";"obs64"="OBS Studio (64-bit)";"streamlabs"="Streamlabs OBS";"xsplit"="XSplit";
    "bandicam"="Bandicam";"fraps"="Fraps";"dxtory"="Dxtory";"action"="Mirillis Action!";
    "medal"="Medal.tv";"plays"="Plays.tv";"outplayed"="Outplayed";"nvsphelper64"="NVIDIA ShadowPlay Helper";
    "shadowplay"="NVIDIA ShadowPlay";"nvcontainer"="NVIDIA Container (ShadowPlay)";
    "gamebarftsvc"="Xbox Game Bar (FT)";"gamebar"="Xbox Game Bar";"xboxgamebar"="Xbox Game Bar App";
    "gamingservices"="Xbox Gaming Services";"geckomonitor"="NVIDIA GeForce Monitor";
    "gameoverlayui"="Steam Game Overlay";"icecreamrecorder"="Icecream Recorder";
    "flashbackrecorder"="Flashback Recorder";"overwolf"="Overwolf";"parsec"="Parsec"
}

$btnScan.Add_Click({
    $btnScan.Visible    = $false
    $progressBg.Visible = $true
    $lblStep.Visible    = $true
    $lblPct.Visible     = $true
    $panelDone.Visible  = $false
    $progressBar.Width  = 0
    $form.Refresh()

    $scanStart = Get-Date
    $findings  = 0
    $script:moduleResults = @{}
    $script:step = 0
    $script:mcPid = $null

    function Advance($msg) {
        $script:step++
        $pct  = [Math]::Min(100,[int](($script:step / 25) * 100))
        $progressBar.Width = [int](400 * $pct / 100)
        $lblStep.Text = $msg
        $lblPct.Text  = "$pct%"
        [System.Windows.Forms.Application]::DoEvents()
    }

    $bootTime = Get-BootTime
    $winUser  = [System.Environment]::UserName

    Advance "Checking services..."
    $svcs    = @("bam","sysmain","diagtrack","appinfo","dps","pcasvc","dusmsvc","PcaSvc")
    $svcWarn = $false
    foreach ($s in $svcs) {
        $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
        if ($svc) {
            if ($svc.Status -ne "Running") { Add-ModuleData "services" "warn" "$s - STOPPED"; $svcWarn = $true }
            else { Add-ModuleData "services" "info" $svc.Status $s }
        } else { Add-ModuleData "services" "warn" "$s - NOT FOUND"; $svcWarn = $true }
    }
    if (-not $svcWarn) { Add-ModuleData "services" "ok" "All monitored services running normally." }

    Advance "Scanning DNS cache..."
    $suspDomains = @(
        "vape.gg","drip.gg","doomsdayclient.com","wurst-client.tk","wurst-client.net",
        "meteorclient.com","liquidbounce.net","rusherhack.org","aristois.net","novaghast.net",
        "novoline.net","inertiaclient.com","lambdacraft.club","sigmamc.club","sigma-client.com",
        "rise-client.com","rise-client.net","vestigeclient.com","dreamhack.cc","autoclicker.pro",
        "exodus.codes","slinky.gg","lithiumclient.wtf","sparkcrack.net","monolithclient.xyz",
        "strikermc.cc","unicornclient.net","uwuclient.xyz","sapphireclient.cc","stringcleaner.xyz",
        "peinjector.net","ghostclient.cc","nitrobrew.cc","crystalclient.org","cubiclient.cc",
        "reflex-client.net","blevclient.com","exitus.cc","spoofy.cc","crit-client.xyz","nodus.cc",
        "zeroday.gg","hackmc.cc","cheatmc.xyz","xanon.cc","jitter.click","butterfly.gg",
        "autoclicker.io","crackedclients.xyz","nulledmc.xyz"
    )
    $dnsFound = $false; $dnsReported = @{}
    $cacheEntries = Get-DnsClientCache -ErrorAction SilentlyContinue
    foreach ($entry in $cacheEntries) {
        $entryName = ""; try { $entryName = $entry.Entry } catch {}
        if ([string]::IsNullOrEmpty($entryName)) { try { $entryName = $entry.Name } catch {} }
        if ([string]::IsNullOrEmpty($entryName) -or $dnsReported.ContainsKey($entryName)) { continue }
        foreach ($domain in $suspDomains) {
            if ($entryName -eq $domain -or $entryName.EndsWith(".$domain")) {
                $entryData = ""; try { $entryData = $entry.Data } catch {}
                Add-ModuleData "dns" "hit" "$entryName -> $entryData"
                $dnsReported[$entryName] = $true; $findings++; $dnsFound = $true; break
            }
        }
    }
    if (-not $dnsFound) { Add-ModuleData "dns" "ok" "No suspicious domains in DNS cache." }

    Advance "Reading USB history..."
    $usbRoot = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"
    $usbKeys = Get-ChildItem $usbRoot -ErrorAction SilentlyContinue
    if ($usbKeys) {
        foreach ($devClass in $usbKeys) {
            $instances = Get-ChildItem $devClass.PSPath -ErrorAction SilentlyContinue
            foreach ($inst in $instances) {
                $firstConn = ""; $lastConn = ""
                try {
                    $propPath = "$($inst.PSPath)\Properties\{83da6326-97a6-4088-9453-a1923f573b29}"
                    $fr = Get-ItemProperty "$propPath\0065" -ErrorAction SilentlyContinue
                    if ($fr) { $raw = $fr.'(default)'; if (-not $raw) { $raw = ($fr.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | Select-Object -First 1).Value }; if ($raw -and $raw.Count -ge 8) { $firstConn = [DateTime]::FromFileTime([BitConverter]::ToInt64([byte[]]$raw,0)).ToString('yyyy-MM-dd HH:mm') } }
                    $lr = Get-ItemProperty "$propPath\0066" -ErrorAction SilentlyContinue
                    if ($lr) { $raw = $lr.'(default)'; if (-not $raw) { $raw = ($lr.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | Select-Object -First 1).Value }; if ($raw -and $raw.Count -ge 8) { $lastConn = [DateTime]::FromFileTime([BitConverter]::ToInt64([byte[]]$raw,0)).ToString('yyyy-MM-dd HH:mm') } }
                } catch {}
                $devName = $devClass.PSChildName -replace '^Disk&Ven_','' -replace '&Prod_',' ' -replace '&Rev_.*',''
                Add-ModuleData "usb" "info" "First: $(if($firstConn){$firstConn}else{'?'})  Last: $(if($lastConn){$lastConn}else{'?'})" $devName
            }
        }
    } else { Add-ModuleData "usb" "ok" "No USB storage devices in registry." }

    Advance "Reading BAM logs..."
    $bamPath  = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings"
    $bamFlags = @("autoclicker","SystemInformer","processhacker","vape","drip","doomsday",
                  "inject","hook","sigma","wurst","meteor","rise","rusherhack","lambda",
                  "registry.exe","clicker","Nvidia Control Panel","slinky","fileless",
                  "exodus","slinkyhook","jitter","butterfly","autoclick","clicking",
                  "sparkcrack","striker","monolith","unicorn client","uwu client",
                  "sapphire","lithiumclient","dream-injector","Registry Cleaner","Wise",
                  "ccleaner","bleachbit","privazer","glary","auslogics","advancedsystemcare",
                  "cleanmgr","eraser","wipefile","sdelete","fileshredder","hardwipe","killdisk",
                  "freeraser","moo0","cipher","nswiper","ultrawipefile","fcleaner","slimcleaner",
                  "ashampoo","iobit","iobits","treesize","windirstat","spacesniffer","drivewipe")
    $bamExempt = @("cheatbreaker","cheat engine uninstall","cheat engine setup","string","Reduct","MemReduct")
    $bamWarn   = $false
    $userSIDs  = Get-ChildItem $bamPath -ErrorAction SilentlyContinue
    foreach ($sid in $userSIDs) {
        $key = Get-Item $sid.PSPath -ErrorAction SilentlyContinue
        if (-not $key) { continue }
        foreach ($valName in $key.GetValueNames()) {
            $lower    = $valName.ToLower()
            $isExempt = $false
            foreach ($ex in $bamExempt) { if ($lower -match $ex) { $isExempt = $true; break } }
            if ($isExempt) { continue }
            foreach ($f in $bamFlags) {
                if ($lower -match $f) {
                    $binaryData = $key.GetValue($valName)
                    if ($binaryData -and $binaryData.Count -ge 8) {
                        $execTime = [DateTime]::FromFileTime([BitConverter]::ToInt64($binaryData,0))
                        $exeName  = Split-Path $valName -Leaf
                        if ($execTime -gt $bootTime) {
                            Add-ModuleData "bam" "hit" "$exeName  [$($execTime.ToString('HH:mm:ss'))]  THIS SESSION"
                            $findings++
                        } else {
                            Add-ModuleData "bam" "warn" "$exeName  [$($execTime.ToString('yyyy-MM-dd HH:mm'))]  pre-boot"
                        }
                        $bamWarn = $true
                    }
                    break
                }
            }
        }
    }
    if (-not $bamWarn) { Add-ModuleData "bam" "ok" "No flagged executables in BAM logs." }

    Advance "Checking Deleted BAM Keys..."
    $delBamWarn = $false
    $userSIDs = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings" -ErrorAction SilentlyContinue
    foreach ($sid in $userSIDs) {
        $key = Get-Item $sid.PSPath -ErrorAction SilentlyContinue
        if (-not $key) { continue }
        foreach ($valName in $key.GetValueNames()) {
            if ($valName -match "^\\Device\\HarddiskVolume\d+\\(.*)") {
                $drivePath = "C:\" + $matches[1]
                if (-not (Test-Path $drivePath -ErrorAction SilentlyContinue)) {
                    $binaryData = $key.GetValue($valName)
                    if ($binaryData -and $binaryData.Count -ge 8) {
                        $execTime = [DateTime]::FromFileTime([BitConverter]::ToInt64($binaryData,0))
                        if ($execTime -gt $bootTime) {
                            Add-ModuleData "delbam" "hit" "Deleted: $valName  [$($execTime.ToString('HH:mm:ss'))]  THIS SESSION"
                            $findings++
                        } else {
                            Add-ModuleData "delbam" "warn" "Deleted: $valName  [$($execTime.ToString('yyyy-MM-dd HH:mm'))]  pre-boot"
                        }
                        $delBamWarn = $true
                    }
                }
            }
        }
    }
    if (-not $delBamWarn) { Add-ModuleData "delbam" "ok" "No deleted BAM entries found." }

    Advance "Checking hosts file..."
    $hostsEntries = Get-Content "C:\Windows\System32\drivers\etc\hosts" -ErrorAction SilentlyContinue | Where-Object { $_ -notlike "#*" -and $_ -match "\S" }
    if ($hostsEntries) {
        foreach ($l in $hostsEntries) { Add-ModuleData "hosts" "warn" $l }
        $findings++
    } else { Add-ModuleData "hosts" "ok" "No active entries in hosts file." }

    Advance "Scanning installed apps..."
    $targetApps = @(
        "Wise Folder Hider","USBOblivion","BulkFileChanger","CCleaner","Reduct","MemReduct",
        "SystemInformer","ProcessHacker","Autoruns","TCPView","Injector","Loader",
        "Everything","PrivaZer","Eraser","Bleachbit","SDelete","Wise","Registry","Cleaner","String"
    )
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $appWarn = $false
    foreach ($app in $targetApps) {
        $found2 = $false
        foreach ($rp in $regPaths) {
            if (Get-ItemProperty $rp -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match "(?i)$([regex]::Escape($app))" }) { $found2 = $true; break }
        }
        if ($found2) { Add-ModuleData "apps" "hit" "Installed: $app"; $findings++; $appWarn = $true }
    }
    if (-not $appWarn) { Add-ModuleData "apps" "ok" "No suspicious applications detected." }

    Advance "Reading prefetch..."
    $pfTargets = $targetApps + @("SparkCrack","Striker","autoclicker","autoclick","jitter","butterfly",
                                  "slinkyhook","slinky","exodus","vape","drip","dreaminjector","monolith",
                                  "unicorn","uwuclient","sapphire","lithium","stringcleaner","ghostclient",
                                  "nitrobrew","reflexclient","crystalclient","blevclient","exitus",
                                  "peinjector","xanon","zerodayclient","SystemInformer","ProcessHacker",
                                  "CCleaner","CCleaner64","BleachBit","PrivaZer","GlaryUtilities","Glary",
                                  "Auslogics","AdvSystemCare","AdvancedSystemCare","Eraser","WipeFile",
                                  "SDelete","FileShredder","Moo0FileShredder","FreeRaser","HardWipe",
                                  "KillDisk","SlimCleaner","FCleaner","DriveWipe","nswiper","CipherWipe",
                                  "Wise","WiseCare","WiseDisk","WiseRegistry","CleanMgr","DiskCleanup")
    $pfWarn = $false
    foreach ($app in $pfTargets) {
        $clean   = $app -replace '[^a-zA-Z0-9]',''
        $pfItems = Get-ChildItem "C:\Windows\Prefetch" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "(?i)$clean" }
        foreach ($pf in $pfItems) {
            if ($pf.LastWriteTime -gt $bootTime) {
                Add-ModuleData "prefetch" "hit" "$($pf.Name)  [$($pf.LastWriteTime.ToString('HH:mm:ss'))]  THIS SESSION"
                $findings++
            } else {
                Add-ModuleData "prefetch" "warn" "$($pf.Name)  [$($pf.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))]  pre-boot"
            }
            $pfWarn = $true
        }
    }
    if (-not $pfWarn) { Add-ModuleData "prefetch" "ok" "No suspicious prefetch entries found." }

    Advance "Checking recording software..."
    $runningProcs = ((Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProcessName) -join " ").ToLower()
    $recWarn = $false
    foreach ($kv in $recordingSoftwares.GetEnumerator()) {
        if ($runningProcs -match $kv.Key) { Add-ModuleData "recording" "hit" "Running: $($kv.Value)"; $findings++; $recWarn = $true }
    }
    if (-not $recWarn) { Add-ModuleData "recording" "ok" "No recording software detected." }

    Advance "Reading modification times..."
    try {
        $SID = (Get-WmiObject Win32_UserAccount | Where-Object { $_.Name -eq $winUser } | Select-Object -First 1).SID
        if ($SID) {
            $recyclePath = "$($env:SystemDrive)\`$Recycle.Bin\$SID"
            if (Test-Path $recyclePath) {
                $ri = Get-Item -LiteralPath $recyclePath -Force -ErrorAction SilentlyContinue
                if ($ri) {
                    if ($ri.LastWriteTime -gt $bootTime) {
                        Add-ModuleData "modtimes" "hit" "Recycle Bin modified during this session  [$($ri.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))]"
                        $findings++
                    } else {
                        Add-ModuleData "modtimes" "info" $ri.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss') "Recycle Bin last cleared"
                    }
                }
            }
        }
    } catch {}
    try { $exp = Get-Process explorer -ErrorAction SilentlyContinue | Select-Object -First 1; if ($exp) { Add-ModuleData "modtimes" "info" $exp.StartTime.ToString('yyyy-MM-dd HH:mm:ss') "Explorer start" } } catch {}
    Add-ModuleData "modtimes" "info" $bootTime.ToString('yyyy-MM-dd HH:mm:ss') "System boot"

    $foldersToCheck = @(
        @{ label="%%TEMP%%";        path=$env:TEMP },
        @{ label="%%LOCALAPPDATA%%\Temp"; path="$env:LOCALAPPDATA\Temp" },
        @{ label="C:\Windows\Temp"; path="C:\Windows\Temp" },
        @{ label="C:\Windows\Prefetch"; path="C:\Windows\Prefetch" }
    )
    foreach ($fc in $foldersToCheck) {
        try {
            $fi = Get-Item $fc.path -ErrorAction Stop
            $modTime = $fi.LastWriteTime
            Add-ModuleData "modtimes" "info" $modTime.ToString('yyyy-MM-dd HH:mm:ss') "$($fc.label) last modified"
            if ($modTime -gt $bootTime) {
                $itemCount = (Get-ChildItem $fc.path -ErrorAction SilentlyContinue | Measure-Object).Count
                $threshold = if ($fc.path -match "Prefetch") { 15 } else { 5 }
                $countStr  = "$itemCount items"
                if ($itemCount -le $threshold) {
                    Add-ModuleData "modtimes" "hit" "$($fc.label) modified this session AND nearly empty [$countStr] - possible wipe  [$($modTime.ToString('HH:mm:ss'))]"
                    $findings++
                } else {
                    Add-ModuleData "modtimes" "warn" "$($fc.label) modified this session [$($modTime.ToString('HH:mm:ss'))]  [$countStr]"
                }
            }
        } catch {}
    }

    Advance "Checking JNativeHook..."
    $jFound   = $false; $jSeen = @{}
    $jPatterns = @("*JNativeHook*","*slinkyhook*","*slinky_library*","*nativehook*","*rawkeyboard*","*jkey*","*jinput*")
    foreach ($tp in @($env:LOCALAPPDATA + "\Temp", $env:TEMP) | Sort-Object -Unique) {
        if (-not (Test-Path $tp)) { continue }
        foreach ($pat in $jPatterns) {
            Get-ChildItem $tp -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $pat -and $_.Extension -match "\.(dll|jar|so)$" } | ForEach-Object {
                if ($jSeen.ContainsKey($_.FullName)) { return }
                $jSeen[$_.FullName] = $true
                $ts = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
                if ($_.LastWriteTime -gt $bootTime) {
                    Add-ModuleData "jnative" "hit" "$($_.Name)  [$ts]  THIS SESSION`n$($_.FullName)"
                    $findings++
                } else {
                    Add-ModuleData "jnative" "hit" "$($_.Name)  [$ts]  (pre-boot)"
                    $findings++
                }
                $jFound = $true
            }
        }
    }
    if (-not $jFound) { Add-ModuleData "jnative" "ok" "No JNativeHook artifacts found." }

    Advance "Checking executed and deleted files..."
    try {
        $rfCache = "C:\Windows\AppCompat\Programs\RecentFileCache.bcf"
        if (Test-Path $rfCache) {
            $raw2        = [System.IO.File]::ReadAllBytes($rfCache)
            $text2       = [System.Text.Encoding]::Unicode.GetString($raw2)
            $lines2      = $text2 -split "`0" | Where-Object { $_ -like "*.exe" }
            $deletedExes = $lines2 | Where-Object { -not (Test-Path $_) }
            foreach ($d in $deletedExes | Select-Object -First 20) { Add-ModuleData "execdel" "hit" "Deleted EXE: $d"; $findings++ }
            if (-not $deletedExes) { Add-ModuleData "execdel" "ok" "No deleted executables found in RecentFileCache." }
        } else { Add-ModuleData "execdel" "ok" "RecentFileCache not present on this system." }
    } catch { Add-ModuleData "execdel" "ok" "Could not read AppCompat data." }

    Advance "Finding Minecraft..."
    $javaProcs = Get-Process -Name "javaw" -ErrorAction SilentlyContinue
    if ($javaProcs) {
        $jp = $javaProcs | Select-Object -First 1
        $script:mcPid = $jp.Id
        $mcDetailed   = Get-MinecraftInfo -pIDProcess $jp.Id
        $script:mcInfoGlobal = $mcDetailed
        Add-ModuleData "minecraft" "info" $jp.Id "PID"
        Add-ModuleData "minecraft" "info" $jp.StartTime.ToString('yyyy-MM-dd HH:mm:ss') "Start time"
        Add-ModuleData "minecraft" "info" "$([Math]::Round($jp.WorkingSet64/1MB,1)) MB" "Memory"
        Add-ModuleData "minecraft" "info" $mcDetailed.version "Version"
        Add-ModuleData "minecraft" "info" $mcDetailed.client "Client"
        if ($mcDetailed.jvmArgs) { Add-ModuleData "minecraft" "info" $mcDetailed.jvmArgs "JVM args" }
        $safeclients2  = @("Vanilla","Minecraft Forge","Fabric","Quilt","NeoForge","OptiFine","Unknown","N/A")
        $legalClients2 = @("Lunar Client","Badlion Client","Feather Client","LabyMod","Salwyrr Launcher","Prism Launcher","MultiMC","PolyMC","ATLauncher")
        if ($safeclients2 -notcontains $mcDetailed.client -and $legalClients2 -notcontains $mcDetailed.client -and $mcDetailed.client -ne "Unknown") {
            Add-ModuleData "minecraft" "hit" "Unrecognized client: $($mcDetailed.client)"
            $findings++
        }
    } else {
        $script:mcInfoGlobal = @{ running=$false; version="N/A"; client="N/A"; memory="N/A"; threads=0; startTime="N/A"; jvmArgs=""; mods=@() }
        Add-ModuleData "minecraft" "warn" "No javaw.exe found. Minecraft not running." }

    Advance "Running in-instance checks..."
    if ($script:mcPid) {
        $flagged = @{
            "jnativehook"="JNativeHook autoclicker";"vape.gg"="Vape client";"slinky"="Slinky client";
            "exodus.codes"="Exodus client";"lithiumclient"="Lithium client";"dream-injector"="Dream injector";
            "unicorn client"="Unicorn client";"uwu client"="UwU client";"sapphire lite"="Sapphire LITE";
            "pe injector"="PE injector";"cracked by kangaroo"="Cracked cheat marker";"monolith lite"="Monolith Lite";
            "sparkcrack"="SparkCrack";"striker.exe"="Striker";"ghostclient"="Ghost client";
            "nitrobrew"="NitroBrew";"reflex-client"="Reflex client";"crystalclient"="Crystal client";
            "blevclient"="Blev client";"rusherhack"="RusherHack";"meteorclient"="Meteor client";
            "liquidbounce"="LiquidBounce";"aristois"="Aristois"
        }
        $inWarn = $false
        try {
            $wmiIn   = Get-WmiObject Win32_Process -Filter "ProcessId = $($script:mcPid)"
            $cmdLine = $wmiIn.CommandLine.ToLower()
            foreach ($kv in $flagged.GetEnumerator()) {
                if ($cmdLine -match [regex]::Escape($kv.Key.ToLower())) {
                    Add-ModuleData "ininst" "hit" "$($kv.Value)  [$($kv.Key)]"
                    $findings++; $inWarn = $true
                }
            }
        } catch {}
        if (-not $inWarn) { Add-ModuleData "ininst" "ok" "No flagged strings in Minecraft process args." }
    } else { Add-ModuleData "ininst" "warn" "Skipped - Minecraft not running." }

    Advance "Running out-of-instance checks..."
    $suspDlls = @("inject","vape","slinky","slinkyhook","exodus","dream","jnativehook","sparkcrack","striker","unicorn","lithium","dream-injector","ghostclient","nitrobrew","peinjector","xanon")
    $oWarn    = $false
    $dpsSvc   = Get-WmiObject Win32_Process -Filter "Name='svchost.exe'" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($dpsSvc) {
        try {
            $modules = (Get-Process -Id $dpsSvc.ProcessId -ErrorAction SilentlyContinue).Modules
            foreach ($mod in $modules) {
                $modName = $mod.ModuleName.ToLower()
                foreach ($kw in $suspDlls) {
                    if ($modName -match $kw) { Add-ModuleData "outinst" "hit" "Suspicious module: $($mod.ModuleName) in svchost"; $findings++; $oWarn = $true }
                }
            }
        } catch {}
    }
    if (-not $oWarn) { Add-ModuleData "outinst" "ok" "No flagged modules found in svchost." }

    Advance "Checking startup entries..."
    $startupWarn = $false
    foreach ($sf in @([System.Environment]::GetFolderPath("Startup"),[System.Environment]::GetFolderPath("CommonStartup"))) {
        if (-not (Test-Path $sf)) { continue }
        foreach ($item in (Get-ChildItem $sf -ErrorAction SilentlyContinue | Where-Object { $_.Extension -ne ".ini" })) {
            $ts    = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
            $extra = if ($item.LastWriteTime -gt $bootTime) { " - THIS SESSION" } else { "" }
            Add-ModuleData "startup" "hit" "$($item.Name)  [$ts]$extra"
            $findings++; $startupWarn = $true
        }
    }
    if (-not $startupWarn) { Add-ModuleData "startup" "ok" "No entries in Shell:Startup folders." }

    Advance "Scanning for alt accounts..."
    $launcherProfiles = @(
        @{ name="Lunar Client";                 paths=@("$env:USERPROFILE\.lunarclient\settings\game\accounts.json", "$env:USERPROFILE\.lunarclient\settings\game-backup", "$env:USERPROFILE\.lunarclient\settings\game") },
        @{ name="ViaFabricPlus (Vanilla)";      paths=@("$env:APPDATA\.minecraft\config\viafabricplus") },
        @{ name="Stitch";                       paths=@("$env:APPDATA\.minecraft\Stitch") },
        @{ name="LiquidBounce";                 paths=@("$env:APPDATA\CCBlueX\LiquidLauncher\data\gameDir\legacy\LiquidBounce-1.8.9", "$env:APPDATA\CCBlueX\LiquidLauncher\data\gameDir\nextgen\LiquidBounce") },
        @{ name="LiquidBounce (ViaFabricPlus)"; paths=@("$env:APPDATA\CCBlueX\LiquidLauncher\data\gameDir\nextgen\config\viafabricplus") },
        @{ name="Augustus Client";              paths=@("$env:APPDATA\ElectricLauncher\data\data\augustus\augustus\settings") },
        @{ name="CurseForge";                   paths=@("$env:USERPROFILE\curseforge\minecraft\Install") },
        @{ name="Windows Recent";               paths=@("$env:APPDATA\Microsoft\Windows\Recent") },
        @{ name="Badlion Client"; paths=@("$env:APPDATA\.badlion\accounts.json", "$env:APPDATA\Badlion Client\accounts.json") },
        @{ name="Feather Client"; paths=@("$env:APPDATA\FeatherClient\accounts.json") },
        @{ name="LabyMod";        paths=@("$env:APPDATA\.minecraft\LabyMod\accounts.json") },
        @{ name="Prism Launcher"; paths=@("$env:APPDATA\PrismLauncher\accounts.json") },
        @{ name="MultiMC";        paths=@("$env:APPDATA\MultiMC\accounts.json") },
        @{ name="PolyMC";         paths=@("$env:APPDATA\PolyMC\accounts.json") },
        @{ name="Modrinth (Main)";              paths=@("$env:APPDATA\com.modrinth.theseus\profiles.json") },
        @{ name="Modrinth (Sodium/ViaFabric)";  paths=@("$env:APPDATA\ModrinthApp\profiles\Sodium Plus\config\viafabricplus") },
        @{ name="Meteor Client";  paths=@("$env:APPDATA\.minecraft\meteor-client\accounts.json") },
        @{ name="Vanilla";        paths=@("$env:APPDATA\.minecraft\launcher_accounts.json", "$env:APPDATA\.minecraft\launcher_profiles.json", "$env:APPDATA\.minecraft") }
    )
    $altsFound = $false
    foreach ($launcher in $launcherProfiles) {
        foreach ($path in $launcher.paths) {
            if (Test-Path $path) {
                try {
                    $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
                    $names   = [regex]::Matches($content,'"(?:displayName|username|name|minecraftUsername)"\s*:\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
                    if ($names.Count -gt 0) {
                        Add-ModuleData "alts" "info" ($names -join ", ") $launcher.name
                        if ($names.Count -gt 1) { Add-ModuleData "alts" "hit" "$($names.Count) accounts in $($launcher.name)"; $findings++ }
                        $altsFound = $true
                    }
                } catch {}
                break
            }
        }
    }
    if (-not $altsFound) { Add-ModuleData "alts" "ok" "No launcher account files found." }

    Advance "Scanning for AnyDesk files..."
    $anyDeskWarn = $false; $adSeen = @{}
    foreach ($sp in @($env:USERPROFILE,"$env:USERPROFILE\Desktop","$env:USERPROFILE\Downloads","$env:USERPROFILE\Documents",$env:APPDATA,$env:LOCALAPPDATA,$env:TEMP)) {
        if (-not (Test-Path $sp)) { continue }
        try {
            Get-ChildItem $sp -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer -and $_.Extension -eq ".anydesk" } | ForEach-Object {
                if ($adSeen.ContainsKey($_.FullName)) { return }
                $adSeen[$_.FullName] = $true
                $ts = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
                if ($_.LastWriteTime -gt $bootTime) {
                    Add-ModuleData "anydesk" "hit" "$($_.Name)  [$ts]  THIS SESSION`n$($_.FullName)"
                    $findings++
                } else {
                    Add-ModuleData "anydesk" "warn" "$($_.Name)  [$ts]`n$($_.FullName)"
                }
                $anyDeskWarn = $true
            }
        } catch {}
    }
    if (-not $anyDeskWarn) { Add-ModuleData "anydesk" "ok" "No .anydesk files found." }

    Advance "Scanning browser history..."
    $bFound = Get-BrowserHistoryScan -bootTime $bootTime
    if (-not $bFound) { Add-ModuleData "browser" "ok" "No suspicious browser history found." }
    if ($bFound) { $findings++ }

    Advance "Scanning Minecraft memory..."
    if ($script:mcPid) {
        $mFound = Get-JavawMemoryScan -pIDProcess $script:mcPid
        if (-not $mFound) { Add-ModuleData "heap" "ok" "No suspicious strings in javaw memory." }
        if ($mFound) { $findings++ }
    } else { Add-ModuleData "heap" "warn" "Skipped - Minecraft not running." }

    Advance "Detecting virtual machine..."
    $vmDetected = Get-VMDetection
    if ($vmDetected) { $findings++ }

    Advance "Detecting mouse device..."
    Get-MouseInfo

    Advance "Enumerating Shell:Recent..."
    $recentPath  = [System.Environment]::GetFolderPath("Recent")
    $recentFiles = Get-ChildItem $recentPath -ErrorAction SilentlyContinue | Where-Object { $_.Extension -ne ".ini" -and $_.LastWriteTime -gt $bootTime } | Sort-Object LastWriteTime -Descending
    if ($recentFiles) {
        foreach ($rf in $recentFiles) {
            Add-ModuleData "recent" "info" $rf.LastWriteTime.ToString('HH:mm:ss') "[FS] $($rf.BaseName)"
        }
    } else {
        Add-ModuleData "recent" "ok" "No files in Shell:Recent (filesystem) since boot." }
    try {
        $regRecent = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
        $subKeys   = @("") + (Get-ChildItem $regRecent -ErrorAction SilentlyContinue | Select-Object -ExpandProperty PSChildName)
        foreach ($sub in $subKeys) {
            $keyPath = if ($sub -eq "") { $regRecent } else { "$regRecent\$sub" }
            $regKey  = Get-Item $keyPath -ErrorAction SilentlyContinue
            if (-not $regKey) { continue }
            $mruList = $regKey.GetValue("MRUListEx", $null)
            if (-not $mruList -or $mruList.Count -lt 4) { continue }
            $order = @()
            for ($i = 0; $i -lt ($mruList.Count - 3); $i += 4) {
                $idx = [BitConverter]::ToInt32($mruList, $i)
                if ($idx -eq -1) { break }
                $order += $idx
            }
            foreach ($idx in $order) {
                $val = $regKey.GetValue($idx, $null)
                if (-not $val) { continue }
                try {
                    $nameRaw = [System.Text.Encoding]::Unicode.GetString($val)
                    $name    = ($nameRaw -split "`0")[0].Trim()
                    if ($name -and $name.Length -gt 1) {
                        $lbl = if ($sub -eq "") { "[REG] Root" } else { "[REG] $sub" }
                        Add-ModuleData "recent" "info" $name $lbl
                    }
                } catch {}
            }
        }
    } catch { Add-ModuleData "recent" "warn" "Could not read RecentDocs registry key." }

    Advance "Analyzing PowerShell History..."
    Get-PSHistoryScan

    Advance "Checking DisallowRun..."
    $drRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun"
    $drKeyExists = Test-Path $drRegPath -ErrorAction SilentlyContinue
    if ($drKeyExists) {
        try {
            $drKey    = Get-Item $drRegPath -ErrorAction Stop
            $drValues = $drKey.GetValueNames() | Where-Object { $_ -ne "" }
            if ($drValues -and $drValues.Count -gt 0) {
                foreach ($drVal in $drValues) {
                    $blocked = $drKey.GetValue($drVal, "")
                    Add-ModuleData "disallowrun" "warn" $blocked "Blocked (Explorer)"
                }
                Add-ModuleData "disallowrun" "hit" "$($drValues.Count) program(s) blocked via DisallowRun - Explorer restart required to apply"
                $findings++
            } else {
                Add-ModuleData "disallowrun" "ok" "DisallowRun key exists but no entries found." }
        } catch {
            Add-ModuleData "disallowrun" "ok" "DisallowRun key could not be read." }
    } else {
        Add-ModuleData "disallowrun" "ok" "DisallowRun not configured." }

    $elapsed = ((Get-Date) - $scanStart).TotalSeconds
    $lblStep.Text = "Generating report..."
    [System.Windows.Forms.Application]::DoEvents()

    $screenshotB64 = ""
    if ($script:mcPid) {
        $lblStep.Text = "Capturing screenshot..."
        [System.Windows.Forms.Application]::DoEvents()
        $screenshotB64 = Take-Screenshot
    }

    $htmlContent = Export-HtmlReport -findings $findings -elapsed $elapsed -bootTime $bootTime -mcInfo $script:mcInfoGlobal -screenshotB64 $screenshotB64
    $script:reportPath = "$env:TEMP\NSS_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    try {
        [System.IO.File]::WriteAllText($script:reportPath, $htmlContent, [System.Text.Encoding]::UTF8)
        Start-Process $script:reportPath
    } catch {}

    $progressBg.Visible = $false
    $lblStep.Visible    = $false
    $lblPct.Visible     = $false

    if ($findings -eq 0) {
        $lblDoneIcon.ForeColor = $ok
        $lblDoneIcon.Text      = "[OK]"
        $lblDoneMsg.Text       = "Scan complete - no findings. Report opened in browser."
    } else {
        $lblDoneIcon.ForeColor = $warn
        $lblDoneIcon.Text      = "!"
        $lblDoneMsg.Text       = "Scan complete - $findings finding(s). Report opened in browser."
    }
    $panelDone.Visible = $true
    $form.Refresh()
})

$btnOpenFolder.Add_Click({
    if ($script:reportPath -and (Test-Path $script:reportPath)) {
        Start-Process "explorer.exe" "/select,`"$($script:reportPath)`""
    }
})

$btnSSTool.Add_Click({
    $btnSSTool.Enabled = $false
    $btnSSTool.Text    = "Downloading..."
    [System.Windows.Forms.Application]::DoEvents()
    $outPath = "$env:TEMP\SSTool.exe"
    try {
        if (Test-Path $outPath) { Remove-Item $outPath -Force }
        $wcSS = New-Object System.Net.WebClient
        $wcSS.Headers.Add("User-Agent","Mozilla/5.0")
        $wcSS.DownloadFile("https://github.com/Orbdiff/SSTool/releases/download/update/SSTool.exe",$outPath)
        if (Test-Path $outPath) { Start-Process $outPath; $btnSSTool.Text = "Launched!" }
        else { $btnSSTool.Text = "Failed" }
    } catch { $btnSSTool.Text = "Error" }
    $btnSSTool.Enabled = $true
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({ $form.Text = "NearScreensharing Tool  -  $(Get-Date -Format 'HH:mm:ss')" })
$timer.Start()

[void]$form.ShowDialog()
$timer.Stop()
