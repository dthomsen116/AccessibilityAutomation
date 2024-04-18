# Define the registry path
$registryPath = "HKCU:\Control Panel\Desktop"

# Define the values to set
$dpiScalingVerValue = 0x00000125
$logPixelsValue = 0x00000096
$win8DpiScalingValue = 0x00000001

# Set the registry values
New-ItemProperty -Path $registryPath -Name "DpiScalingVer" -Value $dpiScalingVerValue -PropertyType DWord -Force
New-ItemProperty -Path $registryPath -Name "LogPixels" -Value $logPixelsValue -PropertyType DWord -Force
New-ItemProperty -Path $registryPath -Name "Win8DpiScaling" -Value $win8DpiScalingValue -PropertyType DWord -Force
