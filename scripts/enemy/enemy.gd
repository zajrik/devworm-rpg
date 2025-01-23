class_name Enemy extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Animation
@onready var state_machine: StateMachine = $StateMachine

@onready var vision_ray: RayCast2D = $DetectionArea/VisionRay

@onready var attack_area: Area2D = $AttackArea
@onready var attack_delay: Timer = $AttackDelay
@onready var attack_cooldown: Timer = $AttackCooldown

@onready var navigation: NavigationAgent2D = $Navigation
@onready var collider: CollisionPolygon2D = $Collider

@export var speed: float = 15.0
@export var health: int = 25

var hovered := false

# Player reference is guaranteed to be non-null when player_visible is true.
var player: Player = null

var player_visible := false
var player_chase := false

var player_pos := Vector2.ZERO
var player_direction := Vector2.ZERO

var knockback_origin := Vector2.ZERO
var is_knocked_back := false

var facing: Enum.Facing = randi_range(0, Enum.Facing.size() - 1) as Enum.Facing


## Emitted when the enemy is hit by an attack
signal hit

## Emitted when the enemy is killed by an attack
signal kill


## Draw debug information.
func debug_draw() -> void:
    if hovered:
        DebugDraw2D.set_text('enemy health', health)
        DebugDraw2D.set_text('enemy state', state_machine.state.name)
        DebugDraw2D.set_text('enemy attackable', state_machine.state_has_component(&'AttackableStateComponent'))


func _process(_delta: float) -> void:
    debug_draw()


## Set the direction the enemy is facing based on velocity angle.
## Facing will not be updated if velocity length is zero.
func face_velocity() -> void:
    var angle: float = rad_to_deg(velocity.angle())

    if angle >= -135 and angle <= -45:
        facing = Enum.Facing.BACK
    elif angle >= -45 and angle <= 45:
        facing = Enum.Facing.RIGHT
    elif angle >= 45 and angle <= 135:
        facing = Enum.Facing.FRONT
    else:
        facing = Enum.Facing.LEFT


## Handle movement of this enemy (it's own or knockback)
func handle_movement() -> void:
    if is_knocked_back:
        var knockback_direction: Vector2 = global_position - knockback_origin
        set_velocity(knockback_direction.normalized() * speed * 4)

    move_and_slide()


## Attack this enemy
func attack(damage: int, origin: Vector2) -> void:
    ## Don't attack an enemy that isn't attackable (That would be rude!)
    if not state_machine.state_has_component(&'AttackableStateComponent'):
        return

    is_knocked_back = true
    knockback_origin = origin

    health -= damage

    if health <= 0:
        kill.emit()

    else:
        hit.emit()


func _on_attack_area_mouse_entered() -> void:
    hovered = true


func _on_attack_area_mouse_exited() -> void:
    hovered = false
