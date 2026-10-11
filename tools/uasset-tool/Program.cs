using System.IO;
using UAssetAPI;
using UAssetAPI.UnrealTypes;
var v = EngineVersion.VER_UE4_22;
switch (args[0]) {
  case "tojson": File.WriteAllText(args[2], new UAsset(args[1], v).SerializeJson(true)); break;
  case "fromjson": UAsset.DeserializeJson(File.ReadAllText(args[1])).Write(args[2]); break;
}
