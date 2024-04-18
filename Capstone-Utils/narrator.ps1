# Define the path to the Narrator executable
$NarratorExePath = "$env:SystemRoot\System32\Narrator.exe"

# Define the path to the Startup folder
$StartupFolderPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Create a WScript Shell object
$WScriptShell = New-Object -ComObject WScript.Shell

# Create a shortcut object
$Shortcut = $WScriptShell.CreateShortcut("$StartupFolderPath\Narrator.lnk")

# Set properties of the shortcut
$Shortcut.TargetPath = $NarratorExePath
$Shortcut.WorkingDirectory = Split-Path $NarratorExePath
$Shortcut.WindowStyle = 1
$Shortcut.Description = "Narrator Shortcut"
$Shortcut.IconLocation = $NarratorExePath

# Save the shortcut
$Shortcut.Save()