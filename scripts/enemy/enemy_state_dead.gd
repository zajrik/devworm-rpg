extends EnemyState

var timestep: float = 0.0

func enter(previous_state: NodePath, _data: Dictionary = {}) -> void:
    enemy.set_collision_mask_value(LayerNames.PHYSICS_2D.PLAYER, false)
    _animate()


func exit() -> void:
    pass

func physics_process(delta: float) -> void:
    enemy.set_modulate(lerp(
        Color(1.0, 1.0, 1.0, 1.0),
        Color(1.0, 1.0, 1.0, 0.0),
        ease(timestep, 3.5)
    ))

    timestep += (1.0 / 5.0) * delta

    if timestep > 1:
        enemy.queue_free()

    enemy.move_and_slide()

func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    enemy.animation.play(&'death')
