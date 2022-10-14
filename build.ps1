$IPXEGIT = "https://github.com/ipxe/ipxe"
$IPXEGIT_Folder = Join-Path $Home 'tmp/ipxe-legacy'
$BuildFolder = Join-Path $PSScriptRoot 'builds'

if (Test-Path $IPXEGIT_Folder) {
    Set-Location -Path $IPXEGIT_Folder
    git clean -fd
    git reset --hard
    git pull
    Set-Location (Join-Path $IPXEGIT_Folder 'src')
}
else {
    git clone $IPXEGIT $IPXEGIT_Folder
    Set-Location (Join-Path $IPXEGIT_Folder 'src')
}

# Get current header and script from fogproject repo
Write-Host "Copy (overwrite) iPXE headers and scripts..."
Copy-Item -Path "$PSScriptRoot/scripts/default.ipxe" -Destination .
Copy-Item -Path "$PSScriptRoot/config/legacy/general.h" -Destination ./config/
Copy-Item -Path "$PSScriptRoot/config/legacy/settings.h" -Destination ./config/
Copy-Item -Path "$PSScriptRoot/config/legacy/console.h" -Destination ./config/

# Build the files
try {
    make bin/undionly.kpxe EMBED=default.ipxe
    make bin/ipxe.iso EMBED=default.ipxe
}
catch {
    $_.Exception.Message
    exit 1
}

#Build EFI
$IPXEGIT_Folder = Join-Path $Home 'tmp/ipxe-uefi'

if (Test-Path $IPXEGIT_Folder) {
    Set-Location -Path $IPXEGIT_Folder
    git clean -fd
    git reset --hard
    git pull
    Set-Location (Join-Path $IPXEGIT_Folder 'src')
}
else {
    git clone $IPXEGIT $IPXEGIT_Folder
    Set-Location (Join-Path $IPXEGIT_Folder 'src')
}

# Get current header and script from fogproject repo
Write-Host "Copy (overwrite) iPXE headers and scripts..."
Copy-Item -Path "$PSScriptRoot/scripts/default.ipxe" -Destination .
Copy-Item -Path "$PSScriptRoot/config/uefi/general.h" -Destination ./config/
Copy-Item -Path "$PSScriptRoot/config/uefi/settings.h" -Destination ./config/
Copy-Item -Path "$PSScriptRoot/config/uefi/console.h" -Destination ./config/

# Build the files
try {
    make bin-x86_64-efi/ipxe.efi EMBED=default.ipxe
}
catch {
    $_.Exception.Message
    exit 1
}

if (-Not(Test-Path $BuildFolder)) {
    New-Item -ItemType Directory -Path $BuildFolder -Force
}
Get-ChildItem -Path $BuildFolder -Recurse -File | Remove-Item -Force
Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.iso, *.efi, *.kpxe | Move-Item -Destination $BuildFolder -Force