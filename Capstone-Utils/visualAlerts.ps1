# Define the registry path
$registryPath = "HKCU:\Control Panel\Accessibility\SoundSentry"

# Define the values
$flagsValue = "3"
$windowsEffectValue = "3"

# Set the registry values
New-ItemProperty -Path $registryPath -Name "Flags" -Value $flagsValue -PropertyType String -Force
New-ItemProperty -Path $registryPath -Name "WindowsEffect" -Value $windowsEffectValue -PropertyType String -Force
