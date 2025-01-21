extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    DebugDraw2D.set_text('enemy count', get_tree().get_node_count_in_group('enemies'))
    DebugDraw2D.set_text('fps', Engine.get_frames_per_second())
