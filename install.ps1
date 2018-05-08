## Description
#
#  Run this script with Boxstarter on your Windows 10 machine to get a useful
#  Windows Subsystem for Linux
#
## Usage
#
#  If you've not done so already you'll need to set the ExecutionPolicy on the machine:
#
#      Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
#
#  Run this boxstarter by calling the following from an **elevated** command-prompt:
#
#      start http://boxstarter.org/package/nr/url?<URL-TO-RAW-FILE>
#  OR
#      Install-BoxstarterPackage -PackageName <URL-TO-RAW-FILE> -DisableReboots
#
## Credits
#
#  Much of the configuration is taken from Jess Frazelle's gist:
#  https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
#
#  which has some of Nick Craver's gist referenced in it:
#  https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9
#
#  and a couple lines come from CJ Kinni's gist:
#  https://gist.github.com/CJKinni/de205822b0dddd2b18054fe7a29f72bc

Write-Host @'
 =============================
< Windows Subsystem for Linux >
< (Ubuntu >= 16.04) installer >
 =============================
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
'@

if ([Environment]::OSVersion.Version.Major -ne 10) {
  Write-Error 'Upgrade to Windows 10 before running this script'
  Exit
}

if (('Unrestricted', 'RemoteSigned') -notcontains (Get-ExecutionPolicy)) {
  Write-Error @'
The execution policy on your machine is Restricted, but it must be opened up for this
installer with:

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
'@
}

if (!(Get-Command 'boxstarter' -ErrorAction SilentlyContinue)) {
  Write-Error @'
You need Boxstarter to run this script; install with:

. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force; refreshenv
'@
  Exit
}

#--- Windows Update ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -AcceptEula


if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId -lt 1803) {
  Write-Error 'You need to run Windows Update and install Feature Updates to at least version 1803'
  Exit
}

#--- Termporarily disable ---
Disable-WindowsUpdate
Disable-UAC

#--- Fonts
choco install hackfont firacode inconsolata dejavufonts robotofonts droidfonts -y

#--- Windows Subsystems/Features ---
choco install Microsoft-Hyper-V-All -source WindowsFeatures -y
choco install Microsoft-Windows-Subsystem-Linux -source WindowsFeatures -y

#--- Install Ubuntu in WSL
lxrun /install /y

#--- Tools ---
choco install sysinternals -y
choco install autohotkey -y

#--- X server ---
choco install cyg-get -y # install cygwin
refreshenv
cyg-get xorg-server xinit # install cygwin/x

#--- Apps ---
choco install googlechrome -y
choco install firefox -y
choco install docker-for-windows -y
choco install cmder -y
choco install putty -y # installing because we want the pageant ssh agent4

#--- Visual Studio Code
choco install visualstudiocode -y
refreshenv
code --install-extension EditorConfig.EditorConfig
code --install-extension vscodevim.vim
code --install-extension eamodio.gitlens
code --install-extension gerane.Theme-Paraisodark
code --install-extension PeterJausovec.vscode-docker
code --install-extension ms-vscode.PowerShell
code --install-extension christian-kohler.path-intellisense
code --install-extension robertohuertasm.vscode-icons
code --install-extension streetsidesoftware.code-spell-checker
### change lang to GB in config with "cSpell.language": "en-GB"


#--- Git ---
choco install git -y --params "/GitAndUnixToolsOnPath"
refreshenv

git config --global set core.symlinks true
git config --global set core.autocrlf input
git config --global set core.eol lf
git config --global set color.status auto
git config --global set color.diff auto
git config --global set color.branch auto
git config --global set color.interactive auto
git config --global set color.ui true
git config --global set color.pager true
git config --global set color.showbranch auto

#--- Decent bash/WSL terminal - wsltty
choco install -y wsltty

# Finish wsltty setup by setting up shortcuts
$wsl_gen_short = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WSL Generate Shortcuts.lnk'
if(Test-Path $wsl_gen_short) {
    Invoke-Item $wsl_gen_short
}

# Setup weasel-pageant
$url = 'https://github.com/vuori/weasel-pageant/releases/download/v1.1/weasel-pageant-1.1.zip'
$archive = 'C:\tools\weasel-pageant-1-1.zip'
if(!(Test-Path $archive)) {
    Write-Host "[installer.weasel-pageant] Downloading..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "$url" -OutFile "$archive"

    if(Test-Path "$archive") {
        $zipfile = Get-Item "$archive"
        Write-Host "[installer.weasel-pageant] Downloaded successfully"
        Write-Host "[installer.weasel-pageant] Extracting $archive to ${zipfile.DirectoryName}..."
        Expand-Archive $archive -DestinationPath $zipfile.DirectoryName
    } else {
        Write-Error "[installer.weasel-pageant] Download failed"
    }
}

#--- Uninstall unecessary applications that come with Windows out of the box ---

# 3D Builder
Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage

# Alarms
Get-AppxPackage Microsoft.WindowsAlarms | Remove-AppxPackage

# Autodesk
Get-AppxPackage *Autodesk* | Remove-AppxPackage

# Bing Weather, News, Sports, and Finance (Money):
Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
Get-AppxPackage Microsoft.BingWeather | Remove-AppxPackage

# BubbleWitch
Get-AppxPackage *BubbleWitch* | Remove-AppxPackage

# Candy Crush
Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage

# Comms Phone
Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage

# Dell
Get-AppxPackage *Dell* | Remove-AppxPackage

# Dropbox
Get-AppxPackage *Dropbox* | Remove-AppxPackage

# Facebook
Get-AppxPackage *Facebook* | Remove-AppxPackage

# Feedback Hub
Get-AppxPackage Microsoft.WindowsFeedbackHub | Remove-AppxPackage

# Get Started
Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage

# Keeper
Get-AppxPackage *Keeper* | Remove-AppxPackage

# Mail & Calendar
Get-AppxPackage microsoft.windowscommunicationsapps | Remove-AppxPackage

# Maps
Get-AppxPackage Microsoft.WindowsMaps | Remove-AppxPackage

# March of Empires
Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage

# McAfee Security
Get-AppxPackage *McAfee* | Remove-AppxPackage

# Uninstall McAfee Security App
$mcafee = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "McAfee Security" } | select UninstallString
if ($mcafee) {
	$mcafee = $mcafee.UninstallString -Replace "C:\Program Files\McAfee\MSC\mcuihost.exe",""
	Write "Uninstalling McAfee..."
	start-process "C:\Program Files\McAfee\MSC\mcuihost.exe" -arg "$mcafee" -Wait
}

# Messaging
Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage

# Minecraft
Get-AppxPackage *Minecraft* | Remove-AppxPackage

# Netflix
Get-AppxPackage *Netflix* | Remove-AppxPackage

# Office Hub
Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage

# One Connect
Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage

# OneNote
Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage

# People
Get-AppxPackage Microsoft.People | Remove-AppxPackage

# Phone
Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage

# Photos
Get-AppxPackage Microsoft.Windows.Photos | Remove-AppxPackage

# Plex
Get-AppxPackage *Plex* | Remove-AppxPackage

# Skype (Metro version)
Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage

# Sound Recorder
Get-AppxPackage Microsoft.WindowsSoundRecorder | Remove-AppxPackage

# Solitaire
Get-AppxPackage *Solitaire* | Remove-AppxPackage

# Sticky Notes
Get-AppxPackage Microsoft.MicrosoftStickyNotes | Remove-AppxPackage

# Sway
Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage

# Twitter
Get-AppxPackage *Twitter* | Remove-AppxPackage

# Xbox
Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage

# Zune Music, Movies & TV
Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage


#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
Set-TaskbarOptions -Size Small -Dock Top -Combine Full -Lock
Set-TaskbarOptions -Size Small -Dock Top -Combine Full -AlwaysShowIconsOn

# Attempt to stop Cortana and web searching
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows Search' -Name 'Windows Search' -ItemType Key
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name AllowCortana -Type DWORD -Value 0
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name BingSearchEnabled -Type DWORD -Value 0
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name ConnectedSearchUseWeb -Type DWORD -Value 0
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name DisableWebSearch -Type DWORD -Value 1

# Better File Explorer
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1		
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# These make "Quick Access" behave much closer to the old "Favorites"
# Disable Quick Access: Recent Files
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0
# Disable Quick Access: Frequent Folders
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0
# To Restore:
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 1
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 1

# Disable the Lock Screen (the one before password prompt - to prevent dropping the first character)
If (-Not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization)) {
	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization | Out-Null
}
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1
# To Restore:
# Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1

# Use the Windows 7-8.1 Style Volume Mixer
If (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name MTCUVC | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 0
# To Restore (Windows 10 Style Volume Control):
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 1

# Disable Xbox Gamebar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

# Turn off People in Taskbar
If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
}
Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

# Flip the scroll wheel direction
# Natural mouse wheel scroll FlipFlopWheel = 1 
# Default mouse wheel scroll FlipFlopWheel = 0 
Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Enum\HID\*\*\Device` Parameters FlipFlopWheel -EA 0 | ForEach-Object { Set-ItemProperty $_.PSPath FlipFlopWheel 1 }

#--- Restore Temporary Settings ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -AcceptEula

if (!(Get-Command 'wsl' -ErrorAction SilentlyContinue)) {
  Write-Error @'
You need Windows Subsystem for Linux setup before the rest of this script can run.

See https://docs.microsoft.com/en-us/windows/wsl/install-win10 for more information.
'@
  Exit
}

if ((wsl awk '/^ID=/' /etc/*-release | wsl awk -F'=' '{ print tolower(\$2) }') -ne 'ubuntu') {
  Write-Error 'Ensure Windows Subsystem for Linux is setup to run the Ubuntu distribution'
  Exit
}

if ((wsl awk '/^DISTRIB_RELEASE=/' /etc/*-release | wsl awk -F'=' '{ print tolower(\$2) }') -lt 16.04) {
  Write-Error 'You need to install a minimum of Ubuntu 16.04 Xenial Xerus before running this script'
  Exit
}
$windows_bash_script_path = [regex]::Escape($PSScriptRoot) + '\\install.sh'
$linux_bash_script_path=(wsl wslpath -a "$windows_bash_script_path")
wsl cp "$linux_bash_script_path" "/tmp/"

wsl bash -c "/tmp/install.sh"

refreshenv