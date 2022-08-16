

# ================================
# Script Begin
# ================================


#
# 1. Gather all Windows Version related information from the Registry and output it to the PowerShell console
#

# All neccessary version info is here (after all subdirs)
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion

# Ex: 	"Microsoft Windows NT 10.0.19042.0"
$OSVersionString = ([Environment]::OSVersion).VersionString

# Ex: 19042		Same as 'CurrentBuildNumber'
$BuildVersion = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild).CurrentBuild

# Ex: "19041.1.amd64fre.vb_release.191206-1406"
$BuildInternalName = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name BuildLabEx).BuildLabEx 

# Not used
# Ex: 2009	Meaning [20]20 September (09)
$InitialInstallRelease = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseId).ReleaseId

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



#
# 2. Read the Created Date on C:\WINDOWS (%SystemRoot%) to gather the date installed
#
#	  FileSystemTime properties - https://docs.microsoft.com/en-us/dotnet/api/system.io.filesysteminfo.creationtime?view=net-6.0
#
$DateFirstInstalled = (Get-Item $env:SystemRoot).CreationTime



#
# 2a. Read the InstallDate (REG_DWORD Seconds-since 1-1-1970 UTC EPoch (UNIX)  or InstallTime (REG_QWORD representing FILETIME which is a 100 nanosecond since 1-1-1601 UTC  EPoch)
#     https://en.wikipedia.org/wiki/Epoch_(computing)
#
#     Both represent the same value in UTC timezone. It's easiest to convert from the REG_DWORD since that is simply adding [n] seconds read in decimal to 1-1-1970 12:00:00

# Going for the InstallDate (REG_DWORD)
$installedDateSecondsSinceEpoch = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name InstallDate).InstallDate

$unixEpoch1970 = [DateTime]"1970-1-1 12:00:00 am"
$DateLastUpgradedOrReinstalled = $unixEpoch1970.AddSeconds($installedDateSecondsSinceEpoch)
# UTC --> Current timezone
$DateLastUpgradedOrReinstalled = $DateLastUpgradedOrReinstalled.ToLocalTime()



#
# 2b. Age since last In-Place upgrade or Win10 / 11 Feature Update
#

# Subtract 2 dates
$age = New-TimeSpan -Start $DateLastUpgradedOrReinstalled -End (Get-Date)

#Date math
$years = [int]($age.Days / 365)
$daysRemainder = $age.Days % 365
#$hours = $age.Hours
$ageFormatted = @"
	$years Years and $daysRemainder Days
"@
# Note: Here-string must be @" "@






#
# 2c. Age since birth (1st install) according to the created date on the C:\Windows directory
#

$ageBorn = New-TimeSpan -Start $DateFirstInstalled -End (Get-Date)

#Date math
$years = [int]($ageBorn.Days / 365)
$daysRemainder = $ageBorn.Days % 365
#$hours = $ageBirth.Hours
$ageBornFormatted = @"
	$years Years and $daysRemainder Days
"@




#
# 3. Uptime
#
# 	From: https://www.tutorialspoint.com/how-to-get-the-system-uptime-with-powershell
#
#	Date .ToString() formatting 
#	     https://www.sconstantinou.com/powershell-date-format/
#	     'ddd' = Abbreviated day of the week
$bootDateTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
$uptime = (Get-Date) - $bootDateTime
$years2 = [int]($uptime.Days / 365)
$daysRemainder2 = $uptime.Days % 365
$totalDaysRounded = [Math]::Round($uptime.TotalDays, 2)
$bootDateTimeFormatted = $bootDateTime.ToString("ddd M-d-yy h:m") +$bootDateTime.ToString("tt").ToLower().Substring(0, 1)

$pluralYears = ""; if($years2 -gt 1 -or $years2 -eq 0) { $pluralYears = "s" }
$pluralDays = ""; if($daysRemainder2 -gt 1 -or $daysRemainder2 -eq 0) { $pluralDays = "s" }
$pluralHours = ""; if($uptime.Hours -gt 1 -or $uptime.Hours -eq 0) { $pluralHours = "s" }
$pluralMins = ""; if($uptime.Minutes -gt 1 -or $uptime.Minutes -eq 0) { $pluralMins = "s" }
$pluralSecs = ""; if($uptime.Seconds -gt 1 -or $uptime.Seconds -eq 0) { $pluralSecs = "s" }

#$uptimeFormatted = @"
#	$totalDaysRounded Days ==> ($years2 Year$($pluralYears) $daysRemainder2 Day$($pluralDays) $($uptime.Hours) Hour$($pluralHours) $($uptime.Minutes) Minute$($pluralMins) $($uptime.Seconds) Second$($pluralSecs)) ==> $bootDateTimeFormatted
#"@

# Dont bother showing Years in Uptime
$uptimeFormatted = @"
	$totalDaysRounded Days ==>    $daysRemainder2 Day$($pluralDays) $($uptime.Hours) Hour$($pluralHours) $($uptime.Minutes) Minute$($pluralMins) $($uptime.Seconds) Second$($pluralSecs)
	        $bootDateTimeFormatted
"@


#
# 4. Here-String construction + Print it all
#

# A Here-String is utilized here as an example vs VBScript
#		'Windows PowerShell Tip of the Week' : Using Windows PowerShell "Here-Strings"
#		https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-powershell-1.0/ee692792(v=technet.10)

$oneLiner = @" 
$EditionName ($KernelVer)  |  Release: $ReleaseFriendly  |   Build: $BuildVersion ($BuildInternalName)
"@

$foramatDate1 = $DateLastUpgradedOrReinstalled.ToString("M-d-yyyy (dddd)   @ h:mm tt")
$formatDate2 = $DateFirstInstalled.ToString("M-d-yyyy (dddd)   @ h:mm tt")

$concatOutput = 
@"
`n
Uptime:  $uptimeFormatted`n`n
$oneLiner `n`n
      Release Version Name:   $ReleaseFriendly
	  
      Build Version:          $BuildVersion    	
      Build Internal Name:    $BuildInternalName `n 
      OS Ver String:          $OSVersionString 
      Edition:                $Edition ($EditionName)
      OS Kernel Revision:     $KernelVer `n
      OS Age:         $ageFormatted
      OS Age Born:    $ageBornFormatted
      
      Last Reinstall or In-Place Upgrade Date:  $foramatDate1  ($([Math]::Round($age.TotalDays, 2)) days ago)
      Initial Install Date (Born):              $formatDate2  ($([Math]::Round($ageBorn.TotalDays, 2)) days ago)`n`n
	  
	  `n`n`n
--------------------
Win10 Releases:
https://en.wikipedia.org/wiki/Windows_10_version_history#Channels

Win11 Releases:
https://en.wikipedia.org/wiki/Windows_11_version_history#Channels
--------------------
`n`n`n
"@

# Clear
CLS

$host.ui.RawUI.WindowTitle = "WinVer2 - Windows Verbose Version Info"

Write-Host $concatOutput

# Pause
Read-Host










#
# Notes
#

# --------------------------------------------------------------
#	PowerShell learnings from creating this script
# --------------------------------------------------------------
#
#	Here-String Tips:
#		- Opt for Here-Strings for large string formatting (Display, Concatenation)
#		- A here-String adds a new line when you add a new line. Therefore to add additional simply utilize `n
#		- Opt for using [Space]s instead of [Tab]s for indentation. Tabs are interpreted as simply 1 space 
#		- Double and Single quotes are allowed within, and around $ variables which will resolve succesfully like a string.Format {0}
#		- To evaluate the expression of a variable simply include it with. $var
#		- To evaluate the expression of an expression, surround it with $(). For example $($date.ToString("ddd"))
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
#		- Here-string must utilize double quotes via @" "@, NOT single quotes
#
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
