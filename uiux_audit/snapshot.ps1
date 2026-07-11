# Helper: Chụp screenshot + lưu UI tree cho màn hình hiện tại
# Usage: powershell -File snapshot.ps1 -ScreenName "01_home"
param(
  [Parameter(Mandatory=$true)] [string]$ScreenName
)
$ErrorActionPreference = 'Continue'
$folder = 'C:\Users\ADMIN\Downloads\prm_prj\TradeLink\uiux_audit'
$pngPath = "/sdcard/$ScreenName.png"
$localPng = Join-Path $folder "$ScreenName.png"
$localTxt = Join-Path $folder "$ScreenName.txt"

Write-Host "=== Snapshot $ScreenName ==="
adb -s emulator-5554 shell screencap -p $pngPath 2>&1 | Out-Null
adb -s emulator-5554 pull $pngPath $localPng 2>&1 | Out-Null
adb -s emulator-5554 shell rm $pngPath 2>&1 | Out-Null

# Dump UI hierarchy to file via uiautomator
adb -s emulator-5554 shell uiautomator dump /sdcard/ui.xml 2>&1 | Out-Null
adb -s emulator-5554 pull /sdcard/ui.xml "$localTxt.ui.xml" 2>&1 | Out-Null
adb -s emulator-5554 shell rm /sdcard/ui.xml 2>&1 | Out-Null

$png = Get-Item $localPng -ErrorAction SilentlyContinue
$xml = Get-Item "$localTxt.ui.xml" -ErrorAction SilentlyContinue
Write-Host "PNG: $($png.Length) bytes" -ErrorAction SilentlyContinue
Write-Host "XML: $($xml.Length) bytes" -ErrorAction SilentlyContinue