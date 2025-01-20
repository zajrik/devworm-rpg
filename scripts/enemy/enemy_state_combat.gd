extends EnemyState

func enter(previous_state: NodePath, data: Dictionary = {}) -> void:
    super(previous_state, data)

    _animate()

func exit() -> void:
    super()

func physics_process(delta: float) -> void:
    enemy.handle_movement()

func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'idle_front')
        Enum.Facing.BACK: enemy.animation.play(&'idle_back')
        _: enemy.animation.play(&'idle_side')
