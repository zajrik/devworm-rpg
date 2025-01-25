class_name SlimeMovementComponent extends MovementComponent

## Direct the associated entity to move to the specified destination.
## Returns the remaining distance to the destination.
@warning_ignore('unused_parameter')
func move_to(destination: Vector2) -> float:
    return 0.0


## Direct the associated entity to navigate to the specified destination.
@warning_ignore('unused_parameter')
func navigate_to(destination: Vector2) -> void:
    pass
