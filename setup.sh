#!/usr/bin/env bash
# Builds tools/bin/uasset-tool (self-contained Linux binary). Needs: git, .NET 10 SDK.
# UAssetAPI (MIT, not part of this repo) is cloned into deps/ at the commit this mod was tested with.
set -euo pipefail
R="$(cd "$(dirname "$0")" && pwd)"
UASSETAPI_COMMIT=3228c1e86261aa08131f7ec0ff1a395f5d0b2a84

if [ ! -d "$R/deps/UAssetAPI" ]; then
    git clone https://github.com/atenfyr/UAssetAPI "$R/deps/UAssetAPI"
    git -C "$R/deps/UAssetAPI" checkout "$UASSETAPI_COMMIT"
fi
DOTNET_CLI_TELEMETRY_OPTOUT=1 dotnet publish "$R/tools/uasset-tool/tool.csproj" -c Release -r linux-x64 --self-contained \
    -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o "$R/tools/bin"
rm -f "$R"/tools/bin/*.pdb "$R"/tools/bin/*.xml
echo "Built $R/tools/bin/uasset-tool"
