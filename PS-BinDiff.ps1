<#
    .SYNOPSIS
    Shows the differences between binaries and generates a patch.

    .DESCRIPTION
    Compares two binary files and generates a patch file in PowerShell.
    The generated patch checks the file hash and makes a backup before applying modifications.

    .PARAMETER OriginalFile
    Specifies the original binary file name.

    .PARAMETER PatchedFile
    Specifies the modified binary file name.

    .EXAMPLE
    PS> .\PS-BinDiff.ps1

    .EXAMPLE
    PS> .\PS-BinDiff.ps1 -OriginalFile program.exe -PatchedFile program_modified.exe

    .LINK
    https://github.com/belane/PS-BinDiff
#>


## ARGUMENTS
param (
    [string]$OriginalFile,
    [string]$PatchedFile
 )

## ORIGINAL BINARY
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
if (!$OriginalFile -or !(Test-Path $OriginalFile)) {
    $OpenFileDialog.ShowDialog() | Out-Null
    if (!$OpenFileDialog.filename) { break }
    $OriginalFile = $OpenFileDialog.filename
}

## FILE DETAILS
$OriginalFile = (Resolve-Path $OriginalFile).ProviderPath
$original = [System.IO.File]::ReadAllBytes($OriginalFile)
$name = Split-Path -Path $OriginalFile -Leaf
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$hash = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($OriginalFile)))

## MODIFIED BINARY
if (!$PatchedFile -or !(Test-Path $PatchedFile)) {
    $OpenFileDialog.filename = ""
    $OpenFileDialog.ShowDialog() | Out-Null
    if (!$OpenFileDialog.filename) { break }
    $PatchedFile = $OpenFileDialog.filename
}
$PatchedFile = (Resolve-Path $PatchedFile).ProviderPath
$patched = [System.IO.File]::ReadAllBytes($PatchedFile)

## DIFFERENCES
$changes = @()
Write-Output "`nOffset`t`tOrg  New`n------------------------"
for ($byte=0; $byte -le $original.Length; $byte++) {
    if ($original[$byte] -ne $patched[$byte]) {
        Write-Output "$('{0:X8}' -f $byte)`t$('{0:X2}' -f $original[$byte])   $('{0:X2}' -f $patched[$byte])"
        $changes += ,@($byte,$original[$byte],$patched[$byte])
    }
}
Write-Output "------------------------`nFound $($changes.Length) changes`n"

## GENERATE PATCH
Write-Output "Generating patch...`n"
$patch_file = ($name + "_PATCH.ps1")
Set-Content $patch_file "## VALUES"
Add-Content $patch_file "`$name = `"$name`""
Add-Content $patch_file "`$hash = `"$hash`""
Add-Content $patch_file "`$changes = @(" -NoNewline
$changes | % { Add-Content $patch_file "($($_[0]),$($_[2]))," -NoNewline }
Add-Content $patch_file "0)`r`n"
## patch code
@'
## OPEN FILE
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.filter = "$name|$name"
$OpenFileDialog.ShowDialog() | Out-Null
if (!$OpenFileDialog.filename) { break }

## CHECKSUM VERIFY
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
if ($hash -ne [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($OpenFileDialog.filename)))) { Write-Output "Checksum error"; break }

## BACKUP FILE
Copy-Item -Path $OpenFileDialog.filename -Destination ($OpenFileDialog.filename + ".bak")

## READ FILE
$binary = [System.IO.File]::ReadAllBytes($OpenFileDialog.filename)
$patch_bin = $OpenFileDialog.filename

## PATCH
$byte_change = 0
Write-Output  "Patching..."
for ($byte=0; $byte -lt $binary.Length; $byte++) {
    if ($byte -eq $changes[$byte_change][0]) {
        Write-Output "$('{0:X8}' -f $changes[$byte_change][0])  $('{0:X2}' -f $changes[$byte_change][1])"
        $binary[$byte] = $changes[$byte_change][1]
        $byte_change++
        if ($byte_change -eq $changes.Length-1) { break }
    }
}

## WRITE FILE
Write-Output "`nWriting..."
[System.IO.File]::WriteAllBytes($patch_bin, $binary)
Write-Output "`nDone!"
'@ | Add-Content $patch_file
Write-Output "$patch_file ready!"
