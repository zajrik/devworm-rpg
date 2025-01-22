extends EnemyState

@export var idle_time_min: float = 3.0
@export var idle_time_max: float = 5.0

@onready var idle_timer: Timer = $IdleTimer

func enter(_previous_state: NodePath, _data: Dictionary = {}) -> void:
    enemy.set_velocity(Vector2.ZERO)

    idle_timer.timeout.connect(_on_wander_timer_timeout)
    idle_timer.start(randf_range(idle_time_min, idle_time_max))

    _animate()

func exit() -> void:
    idle_timer.timeout.disconnect(_on_wander_timer_timeout)
    idle_timer.stop()


func physics_process(_delta: float) -> void:
    enemy.handle_movement()

func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'idle_front')
        Enum.Facing.BACK: enemy.animation.play(&'idle_back')
        _: enemy.animation.play(&'idle_side')

func _on_wander_timer_timeout() -> void:
    transition.emit(WANDER)
