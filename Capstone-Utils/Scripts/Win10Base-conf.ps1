New-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "NarratorCursorHighlight" -Value 1 -PropertyType DWORD -Force;
New-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "FollowInsertion" -Value 1 -PropertyType DWORD -Force;
New-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "CoupleNarratorCursorKeyboard" -Value 1 -PropertyType DWORD -Force;
New-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "InteractionMouse" -Value 1 -PropertyType DWORD -Force;
New-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "CoupleNarratorCursorMouse" -Value 1 -PropertyType DWORD -Force;
$languages = @()
$languages += "en-US"
Set-WinUserLanguageList -LanguageList $languages -Force
