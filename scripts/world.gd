extends Node2D

@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy
@onready var enemy_2: Enemy = $Enemy2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    DebugDraw2D.set_text('1: fps', Engine.get_frames_per_second())
    DebugDraw2D.set_text('2: enemy count', get_tree().get_node_count_in_group('enemies'))
    #DebugDraw2D.set_text('3: enemy 1 sees enemy 2', enemy.vision.can_see(enemy_2))
    #DebugDraw2D.set_text('4: enemy 2 sees enemy 1', enemy_2.vision.can_see(enemy))
    #DebugDraw2D.set_text('5: enemy 1 sees player', enemy.vision.can_see(player))
    #DebugDraw2D.set_text('6: enemy 2 sees player', enemy_2.vision.can_see(player))
