class_name Enemy extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Animation

@onready var vision_ray: RayCast2D = $DetectionArea/VisionRay

@onready var attack_area: Area2D = $AttackArea
@onready var attack_delay: Timer = $AttackDelay
@onready var attack_cooldown: Timer = $AttackCooldown

@export var speed: float = 15.0
@export var health: int = 25

var hovered := false

# Player reference is guaranteed to be non-null when player_visible is true.
var player: Player = null

var player_visible := false
var player_chase := false

var player_pos := Vector2.ZERO
var player_direction := Vector2.ZERO

var can_attack := false

var knockback_origin := Vector2.ZERO

var is_dead := false
var is_knocked_back := false

var timestep: float = 0.0

enum State {
    IDLE,
    MOVE,
    ATTACK,
    HURT,
    DEAD,
}

enum Facing {
    FRONT,
    BACK,
    LEFT,
    RIGHT,
}

var state: State = State.IDLE
var facing: Facing = Facing.FRONT

func _ready() -> void:
    facing = randi_range(0, Facing.size() - 1) as Facing

## Observe and chase player on every physics frame.
func _physics_process(delta: float) -> void:
    debug_draw()

    # Don't chase/attack player if we've entered the DEAD state
    if state != State.DEAD:
        observe_player()
        chase_player()
        attack_player()

    # Wait until death has been confirmed so we can play death animation
    if not is_dead:
        animate_self()

     # Acknowledge death (RIP)
    if state == State.DEAD:
        is_dead = true



    # Ease-out opacity and queue free on death
    if is_dead:
        set_modulate(lerp(Color(1, 1, 1, 1), Color(1, 1, 1, 0.0), ease(timestep, 3.5)))

        timestep += (1.0 / 5.0) * delta

        if timestep > 1:
            queue_free()

    handle_knockback()

    move_and_slide()

## Draw debug information.
func debug_draw() -> void:
    #DebugDraw2D.set_text('player pos', player_pos)
    #DebugDraw2D.set_text('player dir', player_direction.normalized())
    #DebugDraw2D.set_text('player chase', player_chase)
    #DebugDraw2D.set_text('player visible', player_visible)

    if hovered:
        DebugDraw2D.set_text('can attack', can_attack)
        DebugDraw2D.set_text('enemy timestep', timestep)
        DebugDraw2D.set_text('enemy dead', is_dead)
        DebugDraw2D.set_text('enemy health', health)
        DebugDraw2D.set_text('enemy state', state)

## Cast vision ray towards player if player is within range (player_visible).
func observe_player() -> void:
    if state == State.DEAD: return
    if is_dead: return

    if player_visible:
        player_pos = player.global_position
        player_direction = player_pos - global_position

        vision_ray.look_at(player_pos)

        if vision_ray.get_collider() is Player and not player_chase:
            player_chase = true

    else:
        vision_ray.look_at(global_position + Vector2.DOWN)

## Chase player (if they have been seen).
func chase_player() -> void:
    if state == State.DEAD: return

    if not is_knocked_back and not player_chase: return

    # Chase player!
    if player_direction.length() > 15:
        state = State.MOVE if state != State.ATTACK else State.ATTACK

        set_velocity(player_direction.normalized() * 15.0)

    # Stop chasing player if we get too close (personal space!)
    else:
        player_chase = false

        if state != State.ATTACK:
            state = State.IDLE

        set_velocity(Vector2.ZERO)

## Set animation based on state and facing direction.
func animate_self() -> void:
    # Set facing based on velocity direction
    if velocity.length() > 0:
        var angle: float = rad_to_deg(velocity.angle())

        if angle >= -135 and angle <= -45:
            facing = Facing.BACK
        elif angle >= -45 and angle <= 45:
            facing = Facing.RIGHT
        elif angle >= 45 and angle <= 135:
            facing = Facing.FRONT
        else:
            facing = Facing.LEFT

    match state:
        State.IDLE:
            match facing:
                Facing.FRONT: animation.play(&'idle_front')
                Facing.BACK: animation.play(&'idle_back')
                Facing.RIGHT:
                    animation.flip_h = false
                    animation.play(&'idle_side')
                Facing.LEFT:
                    animation.flip_h = true
                    animation.play(&'idle_side')

        State.MOVE:
            match facing:
                Facing.FRONT: animation.play(&'move_front')
                Facing.BACK: animation.play(&'move_back')
                Facing.RIGHT:
                    animation.flip_h = false
                    animation.play(&'move_side')
                Facing.LEFT:
                    animation.flip_h = true
                    animation.play(&'move_side')

        State.ATTACK:
            match facing:
                Facing.FRONT: animation.play(&'attack_front')
                Facing.BACK: animation.play(&'attack_back')
                Facing.RIGHT:
                    animation.flip_h = false
                    animation.play(&'attack_side')
                Facing.LEFT:
                    animation.flip_h = true
                    animation.play(&'attack_side')

        State.HURT:
            match facing:
                Facing.FRONT: animation.play(&'hurt_front')
                Facing.BACK: animation.play(&'hurt_back')
                Facing.RIGHT:
                    animation.flip_h = false
                    animation.play(&'hurt_side')
                Facing.LEFT:
                    animation.flip_h = true
                    animation.play(&'hurt_side')

        State.DEAD:
            animation.play(&'death')

## Attack the tracked player
func attack_player() -> void:
    if is_dead: return

    if attack_cooldown.is_stopped() and attack_delay.is_stopped() and can_attack:
        # Delay starting attack after reaching player to give time to tick dodge
        attack_delay.start()
        await attack_delay.timeout

        # Don't attack if we can no longer attack (player moved away)
        if not can_attack: return

        var prev_state: State = state

        attack_cooldown.start(randf_range(2.5, 3.5))
        state = State.ATTACK

        await get_tree().create_timer(0.4).timeout

        player.attack(randi_range(5, 10))
        player.apply_knockback(global_position)

        state = prev_state

## Attack this enemy. (To be called by the player with a reference to this enemy)
func attack(damage: int) -> void:
    health -= damage

    if health <= 0:
        state = State.DEAD

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
    set_velocity(knockback_direction.normalized() * speed * 4)

## Handle player entering detection area.
func _on_detection_area_body_entered(body: Node2D) -> void:
    player = body as Player
    player_visible = true
    player_pos = player.global_position
    player_direction = player_pos - global_position

    print('what was that...?')

## Handle player exiting detection area.
func _on_detection_area_body_exited(_body: Node2D) -> void:
    player_visible = false

    if player_chase:
        velocity = Vector2.ZERO
        player_chase = false
        state = State.IDLE

        print('i\'ll get you next time!')

    else:
        print('must have been the wind.')

## Handle player entering attack range
func _on_attack_area_body_entered(body: Node2D) -> void:
    if not body is Player: return
    can_attack = true

## Handle player exiting attack range
func _on_attack_area_body_exited(body: Node2D) -> void:
    if not body is Player: return
    can_attack = false


func _on_attack_area_mouse_entered() -> void:
    hovered = true
    print('hovering!')


func _on_attack_area_mouse_exited() -> void:
    hovered = false
    print('not hovering')
