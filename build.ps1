$IPXEGIT = "https://github.com/ipxe/ipxe"
$BuildFolder = Join-Path $PSScriptRoot 'builds'

#--------------------------------------------
#   BIOS and EFI
#--------------------------------------------
$IPXEGIT_Folder = Join-Path $Home 'tmp/ipxe_build'
Get-ChildItem -Path $IPXEGIT_Folder -Recurse | Remove-Item -Force -Recurse

if (-Not(Test-Path $BuildFolder)) {
    New-Item -ItemType Directory -Path $BuildFolder -Force
}
Get-ChildItem -Path $BuildFolder -Recurse -File | Remove-Item -Force

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

#SSL Bug Workaround
#https://github.com/ipxe/ipxe/issues/606#issuecomment-1057367152
Get-ChildItem -Path (Join-Path $PSScriptRoot 'certificates') -File | Copy-Item -Destination ./
$CERTS = (Get-ChildItem ./ -Filter *.pem).FullName -join ','

# Update Configs
Write-Host "Copy (overwrite) iPXE headers and scripts..."
Copy-Item -Path "$PSScriptRoot/scripts/default.ipxe" -Destination .
Copy-Item -Path "$PSScriptRoot/config/general.h" -Destination ./config/
Copy-Item -Path "$PSScriptRoot/config//console.h" -Destination ./config/

# Build the files
try {
    make bin/undionly.kpxe bin/ipxe.lkrn bin-x86_64-efi/ipxe.efi EMBED=default.ipxe TRUST=$CERTS CERT=$CERTS
    ./util/genfsimg -o ipxe.iso bin/ipxe.lkrn bin-x86_64-efi/ipxe.efi
    #gci ./bin/  -Include ipxe.*, undionly.kpxe -Recurse -Exclude *.tmp, *.map
    Get-ChildItem -Path $IPXEGIT_Folder -Recurse -Include undionly.kpxe, ipxe.efi, ipxe.iso | Copy-Item -Destination $BuildFolder -Force
}
catch {
    $_.Exception.Message
    exit 1
}

Set-Location $PSScriptRoot