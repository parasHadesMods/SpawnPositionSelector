ModUtil.RegisterMod("SpawnPositionSelector")

local config = {
  ModName = "Spawn Position Selector",
  PositionNumber = 1
}

if ModConfigMenu then
  ModConfigMenu.Register(config)
end

function ShuffleAsPositionNumber(t)
  local uses = RngDisplayMod.CurrentUses
  RandomSynchronize( config.PositionNumber )
  table.sort(t, cmp_multitype)
  print("shuffle as " .. config.PositionNumber)
  t = FYShuffle( t )
  print("restore to " .. uses)
  RandomSynchronize( uses )
  return t
end

ModUtil.WrapBaseFunction("GetIds", function( basefunc, args )
  local ids = basefunc(args)
  if args.Name and args.Name == "SpawnPoints" then
    ids = ShuffleAsPositionNumber(ids)
  end
  return ids
end)

local spawnPointIdTypes = {}

ModUtil.WrapBaseFunction("GetIdsByType", function( basefunc, args)
  local ids = basefunc(args)
  if args.Name and spawnPointIdTypes[args.Name] then
    ids = ShuffleAsPositionNumber(ids)
  end
  return ids
end)

ModUtil.WrapBaseFunction("SelectSpawnPoint", function(baseFunc, currentRoom, enemy, encounter)
  if enemy.RequiredSpawnPoint then
    spawnPointIdTypes[enemy.RequiredSpawnPoint] = true
  end
  if enemy.PreferredSpawnPoint then
    spawnPointIdTypes[enemy.PreferredSpawnPoint] = true
  end
  local result = baseFunc(currentRoom, enemy, encounter)
  print("Selected " .. result .. " for " .. enemy.Name)
  return result
end)
