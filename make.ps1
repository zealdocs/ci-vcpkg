param(
    [Parameter(Mandatory=$True)]
    [ValidateSet('x86', 'x64')]
    [string]$platform,

    [Parameter(Mandatory=$True)]
    [string]$version
)

# Patch vcpkg
$patches = Get-ChildItem .\patches\*.patch
foreach ($patch in $patches) {
    git apply $patch --directory vcpkg --whitespace=fix
}

# Bootstrap vcpkg
Set-Location -Path vcpkg
.\bootstrap-vcpkg.bat

# Install Zeal dependencies
$triplet = "$platform-windows"
$dependencies = @("libarchive:$triplet", "openssl:$triplet", "sqlite3:$triplet")
.\vcpkg install $dependencies

# Export vcpkg toolchain
.\vcpkg export --raw $dependencies
Get-ChildItem "vcpkg-export-*" | Rename-Item -NewName "vcpkg-export"
.\vcpkg list > .\vcpkg-export\package-list.txt
7z a "vcpkg-export-$version-$platform.7z" ".\vcpkg-export\*"

# Done here
Set-Location -Path ..
