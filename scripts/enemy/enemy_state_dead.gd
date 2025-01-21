extends EnemyState

var timestep: float = 0.0

func enter(previous_state: NodePath, data: Dictionary = {}) -> void:
    super(previous_state, data)

    enemy.collider.call_deferred('set_disabled', true)
    enemy.set_velocity(Vector2.ZERO)

    _animate()

func exit() -> void:
    super()

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
