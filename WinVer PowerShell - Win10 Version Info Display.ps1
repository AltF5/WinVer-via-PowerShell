
# ================================
# Script Begin
# ================================


# 
# 1. Print to the PS window
#

# WMI Query:
$os = Get-CimInstance win32_operatingsystem
$os | Select-Object CSName,LastBootUpTime,
@{Name="Uptime";Expression={(Get-Date) - $_.lastbootuptime}} | Out-Null

$bootDateTime = $os.lastbootuptime
$uptime = (Get-Date) - $os.lastbootuptime
$years2 = [int]($uptime.Days / 365)
$daysRemainder2 = $uptime.Days % 365
$totalDaysRounded = [Math]::Round($uptime.TotalDays, 2)
$bootDateTimeFormatted = $bootDateTime.ToString("ddd M-d-yy h:m") +$bootDateTime.ToString("tt").ToLower().Substring(0, 1)

$pluralYears = ""; if($years2 -gt 1 -or $years2 -eq 0) { $pluralYears = "s" }
$pluralDays = ""; if($daysRemainder2 -gt 1 -or $daysRemainder2 -eq 0) { $pluralDays = "s" }
$pluralHours = ""; if($uptime.Hours -gt 1 -or $uptime.Hours -eq 0) { $pluralHours = "s" }
$pluralMins = ""; if($uptime.Minutes -gt 1 -or $uptime.Minutes -eq 0) { $pluralMins = "s" }
$pluralSecs = ""; if($uptime.Seconds -gt 1 -or $uptime.Seconds -eq 0) { $pluralSecs = "s" }

$uptimeFormatted = @"
	$totalDaysRounded Days =    $years2 Year$($pluralYears) $daysRemainder2 Day$($pluralDays) $($uptime.Hours) Hour$($pluralHours) $($uptime.Minutes) Minute$($pluralMins)
"@

# WMI Query from:
# https://www.tutorialspoint.com/how-to-get-the-system-uptime-with-powershell
#
# And, Formatting TimeSpans
# https://jdhitsolutions.com/blog/powershell/7565/formatting-powershell-timespans/




# 
# 2. Live WinForm counter:
#

# Required!	(Note: Do not put this comment on the same line as Add-Type, otherwise error when copying and pasting in the script)
Add-Type -AssemblyName System.Windows.Forms	
$Form = New-Object 'System.Windows.Forms.Form'
$Form.Text = "Uptime"
$Form.BackColor = "#EFEFEF"		
$Form.Width = 540
$Form.Height = 72
$Form.MaximizeBox = $False
$Form.FormBorderStyle = 'Sizable'
$Form.ShowIcon = $False
$Form.StartPosition = 'CenterScreen'

$clockLbl = New-Object 'System.Windows.Forms.Label'
$clockLbl.Text = ''
$clockLbl.AutoSize = $True
$clockLbl.ForeColor = "#3499CE"						# Text Color in html - https://htmlcolorcodes.com/color-picker/
$clockLbl.Location = New-Object System.Drawing.Point(0,0)
$clockLbl.Font = "DS-Digital,20,style=Bold"
$Form.Controls.Add($clockLbl)

# To avoid a delay, show the initial text right away
# Then repeat below
$upTimeSpan2 = ((Get-Date).AddSeconds(1)) - $os.lastbootuptime		# Add a second
$upFormatted2 = $upTimeSpan2.ToString("d' day 'h' hours 'm' minutes 's' seconds'")
$clockLbl.Text = "" + $upFormatted2


$timer1 = New-Object 'System.Windows.Forms.Timer'
$secondIncreaseCounter = 0
$timer1_Tick={
	$secondIncreaseCounter++
	
	$upTimeSpan2 = (Get-Date).AddSeconds($secondIncreaseCounter) - $os.lastbootuptime		# Add a second
	$upFormatted2 = $upTimeSpan2.ToString("d' day 'h' hours 'm' minutes 's' seconds'")
	
    $clockLbl.Text = "" + $upFormatted2
}

$timer1.Interval = 1000			# Refresh the timer every 1 minute
$timer1.add_Tick($timer1_Tick)
$timer1.Enabled = $True





# 
# 3. Clear & Print first
#

# Here-string:
$print = @"

	`n`n`n
	`t Uptime since booted:   $bootDateTimeFormatted
	
	`t $uptimeFormatted
	`n`n`n
	
"@

cls
ECHO $print



# 
# 4. Show the form (execution hangs here)
#

[void]$Form.ShowDialog()

