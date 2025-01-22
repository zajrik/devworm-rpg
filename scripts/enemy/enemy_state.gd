## Represents a state an Enemy can be in.
##
## Be sure to call super() if overriding _ready().
class_name EnemyState extends State

const IDLE: NodePath = ^'Idle'
const WANDER: NodePath = ^'Wander'
const CHASE: NodePath = ^'Chase'
const ATTACK: NodePath = ^'Attack'
const HURT: NodePath = ^'Hurt'
const DEAD: NodePath = ^'Dead'

var enemy: Enemy

func _ready() -> void:
    await owner.ready

    enemy = owner as Enemy
