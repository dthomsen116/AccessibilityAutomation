# Define the path to the On-Screen Keyboard executable
$OSKExePath = "$env:SystemRoot\System32\osk.exe"

# Define the path to the Startup folder
$StartupFolderPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Create a WScript Shell object
$WScriptShell = New-Object -ComObject WScript.Shell

# Create a shortcut object
$Shortcut = $WScriptShell.CreateShortcut("$StartupFolderPath\OnScreenKeyboard.lnk")

# Set properties of the shortcut
$Shortcut.TargetPath = $OSKExePath
$Shortcut.WorkingDirectory = Split-Path $OSKExePath
$Shortcut.WindowStyle = 1
$Shortcut.Description = "On-Screen Keyboard Shortcut"
$Shortcut.IconLocation = $OSKExePath

# Save the shortcut
$Shortcut.Save()
