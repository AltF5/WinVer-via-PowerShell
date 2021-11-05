

# ------------------------------
#	PowerShell learnings from creating this script below
# ------------------------------
#
#	Here-String Tips:
#		- Opt for Here-Strings for large string formatting (Display, Concatenation)
#		- A here-String adds a new line. Therefore only 1 (or no) additional `n newlines may be neccessary
#		- Opt for using [Space]s instead of [Tab]s for indentation. Tabs are interpreted as simply 1 space 
#		- Double and Single quotes are allowed within, and around $ variables which will resolve succesfully like a string.Format {0}
#
#	Here-String issues encountered (caveats)
#		- Ampersands (&) MUST be escaped withinin here-strings via `& when place within a .ps1 script.
#		  Strangly, copying and pasting into a PowerShell Console incorrectly allows this, leading to believing this is OK. It's NOT, so always escape 
#
#		- Here-Strings starting sequence must NOT have anything directly after the opening @" (including a single blank space) 
#		  Rather, all text must start on a new line (at least this is the behavior when placed in a .ps1 script, rather than pasting into a PS Console.
#		  How a Here-String starts doesn't matter if its on an existing line, or new line, but the key is to never place anything after the opening @"
#		  Bad: 		@" WriteHost Hello @"
#		  Good:		@"
#						Write-Host Hello
#					"@
#
#
# 	PS Registry Access
# 		'Get-ItemProperty' makes every registry value a PSCustomObject object with PsPath, PsParentPath, PsChildname, PSDrive and PSProvider properties and then a property for its actual value. 
#		So even though you asked for the item by name, to get its value you have to use the name once more.
# 		stackoverflow.com/questions/15511809/how-do-i-get-the-value-of-a-registry-key-and-only-the-value-using-powershell
#
#
# ------------------------------
# Win10 Version Info
# ------------------------------
#
#
# Build-only can be seen in:				MSInfo32.exe
# Friendly display info can be seen in: 	explorer.exe ms-settings:about
#
#
# Wiki:
# 	Win10:	https://en.wikipedia.org/wiki/Windows_10_version_history#Channels
#	Win11:	https://en.wikipedia.org/wiki/Windows_11_version_history#Channels
# 
# MS
# https://docs.microsoft.com/en-us/windows/release-health/release-information
#
# Per: https://www.reddit.com/r/PowerShell/comments/pb0ir9/convert_windows_10_build_number_to_feature_update/
#
# [Build Num] : [Release Name Translation]
#	15063 = 1703
#	16299 = 1709
#	17134 = 1803
#	17763 = 1809
#	18362 = 1903
#	18363 = 1909
#	19041 = 2004
#	19042 = 20H2
#	19043 = 21H1
#	19044 = 21H2





# ================================
# Script Begin
# ================================


#
# Gather all Windows Version related information from the Registry and output it to the PowerShell console
#

# All neccessary version info is here (after all subdirs)
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion

# Ex: 	"Microsoft Windows NT 10.0.19042.0"
$OSVersionString = ([Environment]::OSVersion).VersionString

# Ex: 19042		Same as 'CurrentBuildNumber'
$BuildVersion = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild).CurrentBuild

# Ex: "19041.1.amd64fre.vb_release.191206-1406"
$BuildInternalName = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name BuildLabEx).BuildLabEx 

# Ex: 2009	Meaning [20]20 September (09)
$ReleaseYYMM = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseId).ReleaseId

# Ex: 20H2
# This is the Master-Truth.
# Both ms:settings about & winver.exe pull directly from this 'DisplayVersion' REG_SZ value. When changed, they change immediately
$ReleaseFriendly = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name DisplayVersion).DisplayVersion

# Ex: "Professional"
$Edition = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name EditionID).EditionID 

# Ex: "Windows 10 Pro"
$EditionName = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName).ProductName 

# Ex: 6.3
$KernelVer = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentVersion).CurrentVersion



# A Here-String is utilized here as an example vs VBScript - https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-powershell-1.0/ee692792(v=technet.10)?redirectedfrom=MSDN

$oneLiner = @" 
$EditionName ($KernelVer)  |  Release: $ReleaseFriendly ($ReleaseYYMM)  |   Build: $BuildVersion ($BuildInternalName)
"@

$concatOutput = 
@"
`n
          -----------------------------------
          ----- Current OS Version Info -----
          -----------------------------------
	`n`n
$oneLiner `n`n
      Release Name `& YY-MM:  "$ReleaseFriendly"  == '$ReleaseYYMM' 
      Build Version:          $BuildVersion    	
      Build Internal Name:    $BuildInternalName `n 
      OS Ver String:       $OSVersionString 
      Edition:             $Edition ($EditionName)
      OS Kernel Revision:  $KernelVer `n`n
"@

# Clear
CLS

Write-Host $concatOutput

# Pause
Read-Host







