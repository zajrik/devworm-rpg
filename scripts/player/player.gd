class_name Player extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_collider: CollisionPolygon2D = $SwingCollider/CollisionPolygon2D

@export var speed: int = 75
@export var health: int = 25

const move_actions: Array[StringName] = [
    &'move_left',
    &'move_right',
    &'move_up',
    &'move_down',
]

enum PlayerState {
    IDLE,
    WALK,
    ATTACK,
    DEAD
}

enum Facing {
    LEFT,
    RIGHT,
    BACK,
    FRONT,
}

var player_state := PlayerState.IDLE
var facing_direction := Facing.FRONT
var knockback_origin := Vector2.ZERO

var is_dead := false
var is_knocked_back := false

var is_attacking := false

func _ready() -> void:
    swing_collider.set_deferred(&'disabled', true)

func _physics_process(_delta: float) -> void:
    DebugDraw2D.set_text('player health', health)
    DebugDraw2D.set_text('player is_attacking', is_attacking)

    # Wait until death has been confirmed so we can play death animation
    if not is_dead:
        player_movement()
        set_facing()
        animate_self()

    # Acknowledge player's death (RIP)
    if player_state == PlayerState.DEAD:
        is_dead = true

    # Not limited to when not is_dead so that corpse can be knocked around for funsies
    handle_knockback()

    move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(&'attack') and not is_attacking and not is_dead:
        attack_enemies()

## Set player facing state from input.
func set_facing() -> void:
    if Input.is_action_pressed(&'move_left'):
        facing_direction = Facing.LEFT
        swing_collider.set_rotation(deg_to_rad(-180))

    elif Input.is_action_pressed(&'move_right'):
        facing_direction = Facing.RIGHT
        swing_collider.set_rotation(deg_to_rad(0))

    elif Input.is_action_pressed(&'move_up'):
        facing_direction = Facing.BACK
        swing_collider.set_rotation(deg_to_rad(-90))

    elif Input.is_action_pressed(&'move_down'):
        facing_direction = Facing.FRONT
        swing_collider.set_rotation(deg_to_rad(90))

## Play appropriate animation depending on player_state.
func animate_self() -> void:
    match player_state:
        PlayerState.ATTACK:
            match facing_direction:
                Facing.FRONT: animation.play(&'attack_front')
                Facing.BACK: animation.play(&'attack_back')
                Facing.RIGHT:
                    animation.flip_h = false
                    animation.play(&'attack_side')
                Facing.LEFT:
                    animation.flip_h = true
                    animation.play(&'attack_side')

        PlayerState.IDLE:
            match facing_direction:
                Facing.FRONT: animation.play(&'idle_front')
                Facing.BACK: animation.play(&'idle_back')
                Facing.RIGHT:
                    animation.flip_h = false
                    animation.play(&'idle_side')
                Facing.LEFT:
                    animation.flip_h = true
                    animation.play(&'idle_side')

        PlayerState.WALK:
            match facing_direction:
                Facing.FRONT: animation.play(&'walk_front')
                Facing.BACK: animation.play(&'walk_back')
                Facing.RIGHT:
                    animation.flip_h = false
                    animation.play(&'walk_side')
                Facing.LEFT:
                    animation.flip_h = true
                    animation.play(&'walk_side')

        PlayerState.DEAD:
            animation.play(&'death')

## Attack this player. (To be called by enemies with a reference to the player)
func attack(damage: int) -> void:
    health -= damage

    if health <= 0:
        player_state = PlayerState.DEAD

## Apply knockback to the player from the given origin.
func apply_knockback(from: Vector2) -> void:
    if is_knocked_back: return

    knockback_origin = from
    is_knocked_back = true

    await get_tree().create_timer(0.5).timeout

    is_knocked_back = false
    velocity = Vector2.ZERO

## Handle knockback if we are knocked back.
func handle_knockback() -> void:
    if not is_knocked_back: return

    var knockback_direction: Vector2 = global_position - knockback_origin
    set_velocity(knockback_direction.normalized() * speed * 0.5)

## Handle player movement. Disabled for duration of knockbacks.
func player_movement() -> void:
    if is_knocked_back: return

    var direction: Vector2 = Input.get_vector.bindv(move_actions).call()

    if direction.length() > 0.0:
        player_state = PlayerState.WALK if player_state != PlayerState.ATTACK else PlayerState.ATTACK
    else:
        player_state = PlayerState.IDLE if player_state != PlayerState.ATTACK else PlayerState.ATTACK

    set_facing()
    set_velocity(direction.normalized() * speed)

## Swing that sword, baby!
func attack_enemies() -> void:
    if is_attacking: return
    is_attacking = true

    var prev_state := player_state

    player_state = PlayerState.ATTACK
    swing_collider.set_deferred(&'disabled', false)

    await get_tree().create_timer(0.5).timeout

    swing_collider.set_deferred(&'disabled', true)

    is_attacking = false
    player_state = prev_state

## When swing collider hits an enemy. Should only happen once per swing.
## TODO: Write a proper state machine setup for player and enemies and add
## immunity time to player and enemies on hit
func _on_swing_collider_body_entered(body: Node2D) -> void:
    if not is_attacking or not body is Enemy: return

    (body as Enemy).attack(10, global_position)
