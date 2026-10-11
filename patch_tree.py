# Patches a vendor event tree (UAssetAPI JSON) so the shop option opens the menu and ends the conversation:
#   [pre..., ShowMenu, post..., DialogOptions("Ok")] -> [pre..., HideMenu, ShowMenu, post..., <goodbye>]
# <goodbye> = the Event/Achievement nodes (quest state) and the Exit node of the tree's own goodbye trigger.
# Usage: patch_tree.py <in.json> <out.json>
import copy
import json
import sys

src, dst = sys.argv[1], sys.argv[2]
with open(src) as f:
    asset = json.load(f)
exports, imports = asset['Exports'], asset['Imports']


def class_name(i):
    c = exports[i - 1]['ClassIndex']
    return imports[-c - 1]['ObjectName'] if c < 0 else exports[c - 1]['ObjectName']


def prop(i, name):
    return next((p for p in exports[i - 1].get('Data', []) if p['Name'] == name), None)


def child_nodes(i):
    p = prop(i, 'Nodes')
    return [x['Value'] for x in p['Value']] if p else []


def classes(nodes):
    return [class_name(n) for n in nodes]


all_nodes = range(1, len(exports) + 1)

# The goodbye trigger ("Exit" or "Farewell"): the trigger that hides the menu and exits.
goodbye_trigger = next(i for i in all_nodes if class_name(i) == 'EventTreeNode_Trigger'
                       and {'EventTreeNode_HideMenu_C', 'EventTreeNode_Exit'} <= set(classes(child_nodes(i))))
trigger_nodes = child_nodes(goodbye_trigger)
hide_menu = next(n for n in trigger_nodes if class_name(n) == 'EventTreeNode_HideMenu_C')
goodbye = [n for n in trigger_nodes
           if class_name(n) in ('EventTreeNode_Event', 'EventTreeNode_Achievement', 'EventTreeNode_Exit')]

patched = 0
for i in all_nodes:
    nodes = child_nodes(i)
    names = classes(nodes)
    # Shop/crafting/upgrade menus have the ShowMenu value set; the default (unset) is the conversation menu.
    show = next((k for k, n in enumerate(nodes) if names[k] == 'EventTreeNode_ShowMenu_C' and prop(n, 'ShowMenu')), None)
    if show is None:
        continue
    options = next((k for k in range(show + 1, len(nodes)) if names[k] == 'EventTreeNode_DialogOptions'), None)
    if options is None:
        continue

    new_nodes = nodes[:show] + [hide_menu] + nodes[show:options] + goodbye
    p = prop(i, 'Nodes')
    template = p['Value'][0]
    p['Value'] = [dict(copy.deepcopy(template), Name=str(k), Value=n) for k, n in enumerate(new_nodes)]
    print(f"{src}: #{i} {names} -> {classes(new_nodes)}")
    patched += 1

if not patched:
    sys.exit(f"{src}: no vendor menu branch found")
with open(dst, 'w') as f:
    json.dump(asset, f)
