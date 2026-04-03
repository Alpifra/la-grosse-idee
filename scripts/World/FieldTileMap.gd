class_name FieldTileMap
extends TileMapLayer

## Sol du champ — TileMapLayer avec vrais sprites PNG
## Grass_Middle (16x16) comme base, Path_Middle pour chemins, FarmLand pour zone agricole

const FIELD_COLS : int = 40   # 640 / 16
const FIELD_ROWS : int = 30   # 480 / 16

const SRC_GRASS : int = 0
const SRC_PATH  : int = 1
const SRC_FARM  : int = 2

# preload = chargé à l'import, pas au runtime
const _TEX_GRASS = preload("res://assets/sprites/Grass_Middle.png")
const _TEX_PATH  = preload("res://assets/sprites/Path_Middle.png")
const _TEX_FARM  = preload("res://assets/sprites/FarmLand_Tile.png")

const _TILE_SIZE   : Vector2i = Vector2i(16, 16)
const _TILE_ORIGIN : Vector2i = Vector2i(0, 0)

func _ready() -> void:
	_build_tileset()
	_fill_ground()

## Construit le TileSet avec les textures PNG
func _build_tileset() -> void:
	var ts := TileSet.new()
	ts.tile_size = _TILE_SIZE

	var src_grass := TileSetAtlasSource.new()
	src_grass.texture             = _TEX_GRASS
	src_grass.texture_region_size = _TILE_SIZE
	src_grass.create_tile(_TILE_ORIGIN)
	ts.add_source(src_grass, SRC_GRASS)

	var src_path := TileSetAtlasSource.new()
	src_path.texture             = _TEX_PATH
	src_path.texture_region_size = _TILE_SIZE
	src_path.create_tile(_TILE_ORIGIN)
	ts.add_source(src_path, SRC_PATH)

	var src_farm := TileSetAtlasSource.new()
	src_farm.texture             = _TEX_FARM
	src_farm.texture_region_size = _TILE_SIZE
	src_farm.create_tile(_TILE_ORIGIN)
	ts.add_source(src_farm, SRC_FARM)

	tile_set = ts

## Remplit la carte : herbe partout, chemin en croix, zone agricole coin bas-gauche
func _fill_ground() -> void:
	for x in range(FIELD_COLS):
		for y in range(FIELD_ROWS):
			var src := SRC_GRASS
			# Chemin vertical (cols 19-20) et horizontal (lignes 14-15)
			if x == 19 or x == 20 or y == 14 or y == 15:
				src = SRC_PATH
			# Zone agricole bas-gauche (hors chemin)
			elif x < 8 and y > 20:
				src = SRC_FARM
			set_cell(Vector2i(x, y), src, _TILE_ORIGIN)
