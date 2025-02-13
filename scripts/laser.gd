class_name Laser extends Area2D


@export var speed = 600
@export var damage = 1
@export var start_rotation = 0
@export var x_movement = 0
@export var y_movement = 1

@onready var laser_sound = $SFX/LaserSound
@onready var hit_sound = $SFX/HitSound
@onready var type: String

func _ready() -> void:
	laser_sound.play()
	rotation_degrees = start_rotation
		
func _physics_process(delta):
	# go up
	global_position.y += -speed * delta * y_movement
	global_position.x += -speed * delta * x_movement
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# remove if go out of the canvas
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		# delate laser
		area.take_damage(damage)
		queue_free()
	if area is Laser:
		if (type=="player" and area.type == "enemy") or (type=="enemy" and area.type =="player"):
			hit_sound.play()
			area.queue_free()
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Hit Body
	if body is Player:
		# Hit player
		body.die()
		queue_free()
