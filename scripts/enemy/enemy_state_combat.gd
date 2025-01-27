extends EnemyState

## The SimpleVision node that will be used to detect entities we're chasing.
@export var vision: SimpleVision:
    set(value):
        vision = value
        update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
    var result := []

    if vision == null:
        result.append(
            'A SimpleVision node must be set for the component to see entities.'
        )

    return result


var target: CharacterBody2D


func enter(previous_state: NodePath, data: Dictionary = {}) -> void:
    assert(data['target'] != null, 'Combat target data must be provided.')

    target = data['target']

    _animate()

    if not vision.can_detect(target):
        transition.emit(RETURN)
        return

    if not vision.can_see(target):
        transition.emit(CHASE, {'target': target})
        return

    await get_tree().create_timer(randf_range(1.0, 2.0)).timeout
    transition.emit(ATTACK, {'target': target})


func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'idle_front')
        Enum.Facing.BACK: enemy.animation.play(&'idle_back')
        _: enemy.animation.play(&'idle_side')
