extends TileMapLayer

@onready var collision_layer: TileMapLayer = $'../CollisionLayer'

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
    if coords in collision_layer.get_used_cells_by_id(15):
        return true

    return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
    if coords in collision_layer.get_used_cells_by_id(15):
        tile_data.set_navigation_polygon(0, null)
