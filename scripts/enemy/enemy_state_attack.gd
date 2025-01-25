extends EnemyState

## The attack hitbox that will damage target on contact
@export var attack_hitbox: Area2D:
    set(value):
        attack_hitbox = value
        update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
    var result := []

    if attack_hitbox == null:
        result.append(
            'An attack hitbox must be configured to be able to attack targets.'
        )

    return result


var target: CharacterBody2D
var target_location: Vector2 = Vector2.ZERO
var timestep: float = 0.0

func enter(previous_state: NodePath, data: Dictionary = {}) -> void:
    assert(data['target'] != null, 'Attack target data must be provided.')

    target = data['target'] as CharacterBody2D

    print('KIYAAAAA!')

    attack_hitbox.body_entered.connect(_on_body_entered)

    timestep = 0.0
    launch_at(target.global_position)


func exit() -> void:
    attack_hitbox.body_entered.disconnect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body != target: return

    target.attack(5)
    target.apply_knockback(enemy.global_position)

func physics_process(delta: float) -> void:
    if timestep >= 0.5:
        #enemy.set_velocity(Vector2.ZERO)

        transition.emit(COMBAT, {'target': target})
        return

    _animate()

    enemy.velocity -= lerp(enemy.velocity, Vector2.ZERO, ease(timestep * 2.0, 0.2)) * delta

    enemy.handle_movement()

    timestep += delta

func launch_at(location: Vector2) -> void:
    target_location = location
    enemy.set_velocity(enemy.global_position.direction_to(target_location) * 70)
    enemy.face_velocity()


func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'attack_front')
        Enum.Facing.BACK: enemy.animation.play(&'attack_back')
        _: enemy.animation.play(&'attack_side')
