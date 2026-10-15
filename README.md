# CoopMerchants

Remnant: From the Ashes pak mod for co-op. Normally a vendor is busy while one player talks to them.
With this mod, picking a vendor's shop, crafting or upgrade option opens the menu and ends the conversation
right away, so the other player can use the vendor at the same time. Only the hosting player needs it, because
conversations run on the host. Installing it for the other players is harmless too.

Vendors:
- Ward 13: Reggie, Rigs, McCabe, Ace, Whispers, Root Mother.
- Worlds (by quest asset): Earth (MudTooth, MadMerchant), Rhom (HoundMaster, OldManAndConstruct),
  Corsus (ElfQueen, GraveyardElf, BrainBug), Yaesha (StuckMerchant), Reisum (KrallMother, Sebum).

Companion mod: [Ward13MerchantHotkeys](https://github.com/heretic-one/Remnant-From-The-Ashes-Ward13-Merchant-Hotkeys)
opens the Ward 13 vendor menus with F1–F6.

## Install

Extract `CoopMerchants.zip` into the game folder (Steam > Remnant: From the Ashes > Manage > Browse local files).
Result: `Remnant\Content\Paks\~mods\CoopMerchants_P.pak`.

## Uninstall

Delete `Remnant\Content\Paks\~mods\CoopMerchants_P.pak`.

## Compatibility and limitations

- Conflicts with other mods that replace the same vendor event trees (see `trees.txt`).
- The conversation ends when the menu opens. Talk to the vendor again for other dialogue.

## Notes

- Claude code was used in the making of this mod.

## Build (Linux only)

Players don't need to build: use the release zip.
No game files are included: `build.sh` extracts the original event trees from your own game install.

Requirements: `python3`, [repak](https://github.com/trumank/repak), and for `setup.sh` also `git` and the .NET 10 SDK.

```bash
./setup.sh                          # once: builds tools/bin/uasset-tool (clones UAssetAPI into deps/)
GAME=/path/to/Remnant ./build.sh    # -> build/CoopMerchants_P.pak, build/CoopMerchants.zip
```

`GAME` defaults to `~/.local/share/Steam/steamapps/common/Remnant`. `UASSET_TOOL` and `REPAK` override the tool paths.

## How it works

- `trees.txt`: the vendor event trees to patch (game asset paths).
- `patch_tree.py`: in each tree, the shop branch `[..., ShowMenu, ..., DialogOptions("Ok")]` becomes
  `[..., HideMenu, ShowMenu, ..., Exit]`, reusing the tree's own goodbye nodes (plus its quest events/achievements).
- `tools/uasset-tool`: converts `.uasset` to JSON and back with [UAssetAPI](https://github.com/atenfyr/UAssetAPI) (UE 4.22).
