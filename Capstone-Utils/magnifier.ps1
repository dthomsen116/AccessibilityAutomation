# Define the path to the Magnifier executable
$MagnifierExePath = "$env:SystemRoot\System32\Magnify.exe"

# Define the path to the Startup folder
$StartupFolderPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Create a WScript Shell object
$WScriptShell = New-Object -ComObject WScript.Shell

# Create a shortcut object
$Shortcut = $WScriptShell.CreateShortcut("$StartupFolderPath\Magnifier.lnk")

# Set properties of the shortcut
$Shortcut.TargetPath = $MagnifierExePath
$Shortcut.WorkingDirectory = Split-Path $MagnifierExePath
$Shortcut.WindowStyle = 1
$Shortcut.Description = "Magnifier Shortcut"
$Shortcut.IconLocation = $MagnifierExePath

# Save the shortcut
$Shortcut.Save()
