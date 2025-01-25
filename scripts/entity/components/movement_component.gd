## The base MovementComponent for all entities that can move. This should be extended
## to provide more specific movement behaviors for different entity types.
class_name MovementComponent extends Component

## The base base_speed of the associated entity.
@export var base_speed: float = 50.0


## Direct the associated entity to move towards the specified destination.
## Returns the remaining distance to the destination.
@warning_ignore('unused_parameter')
func move_towards(destination: Vector2) -> float:
    return 0.0


## Direct the associated entity to navigate to the specified destination.
@warning_ignore('unused_parameter')
func navigate_to(destination: Vector2) -> void:
    pass
