# Add class as Enemy for laser detection
class_name Enemy extends Area2D

# give info about destryed enemy (player get points)
signal killed(points)
signal hit

const laser_scene = preload("res://scenes/laser.tscn")
signal laser_shot(laser_scene, location, start_rotation, y_movement, x_movement)

enum EnemyType {NORMAL=1, SPEED=2, SHOOTING=3, BOSS=4}
var boss_pos_x = [400, 960, 1520]
var boss_pos_y = [700,250]#[-300, -600]

# Export
@export var type: EnemyType = EnemyType.NORMAL
@export var level = 1

# On ready
@onready var muzzle: Marker2D = $Muzzle
@onready var explode_sound = $SFX/ExpodeSound
@onready var hit_sound = $SFX/HitSound

var is_waiting = true
var is_shooting = false
var speed: int
var move = 100 # change direction
var time_to_change_direction: float = 4
var rate_of_fire = 1.5
var hp: int
var boss: bool = false
var points: int
var teleport: bool = false

func _ready() -> void:
	setup_enemy()
	hp *= level
	points *= level
	# Routine
	var stop:bool = true
	var loop:int = 1
	if !teleport and !is_shooting:
		stop = false
		pass
	else:
		while stop:
			if teleport:
				await get_tree().create_timer(1).timeout
				teleport_func()
			if is_shooting:
				await get_tree().create_timer(rate_of_fire).timeout
				shoot()

func setup_enemy():
	match type:
		1:
			hp = 2
			points = 50
			speed = 150
		2:
			hp = 1
			points = 100
			speed = 300
		3:
			hp = 2
			points = 100
			is_shooting = true
			speed = 50
		4:
			boss = true
			points = 500
			hp = 10
			speed = 0
			is_shooting = true
			teleport = true
		_:
			error("Unknown Enemy Type", scene_file_path)

func teleport_func():
	var change:bool = false
	var x:int
	var y:int
	var x_array_size:int = boss_pos_x.size()
	var y_array_size:int = boss_pos_y.size()
	while change == false:
		x = randi_range(0,x_array_size)%x_array_size
		y = randi_range(0,y_array_size)%y_array_size
		if (boss_pos_x[x-1]!= global_position.x or boss_pos_y[y-1]!= global_position.y):
			change = true
		else:
			print("False")
	change = false
	global_position.x = boss_pos_x[x-1]
	global_position.y = boss_pos_y[y-1]

func change_direction(): 
	is_waiting = false
	await get_tree().create_timer(time_to_change_direction).timeout
	#if move>0:
	move *= -1
	#else:
		#pass
	is_waiting = true

func shoot():
	#is_shooting = true
	var location = muzzle.global_position + Vector2(0,-10)
	if type==4: # Boss is a little bigger
		laser_shot.emit("enemy", laser_scene, muzzle.global_position+Vector2(0,50),0, -1, 0)
	else:
		laser_shot.emit("enemy", laser_scene, muzzle.global_position+Vector2(0,40),0, -1, 0)
		#is_shooting = false

func _physics_process(delta: float) -> void:
	global_position.y += speed * delta
	#if y_movement:
	#	global_position.x += move * delta
	#	#initiate
	if is_waiting:
		change_direction()
	if !is_shooting:
		shoot()
	
func die():
	# Sound
	# remove enemy
	if type == 4:
		boss_dead()
	else:
		queue_free()		

func _on_body_entered(body: Node2D) -> void:
	# Colision with player
	if body is Player and type != 4:
		body.die()
		die()

func take_damage(amount):
	hit_sound.play()
	hp -= amount
	if hp <= 0:
		killed.emit(points)
		die()
	else:
		hit.emit()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# kill when go outside of screen
	queue_free()

func boss_dead():
	queue_free()
	
func error(message:String,info:String):
	print("---ERROR---")
	print(message)
	print("INFO: ",info)
	print("---ERROR---")
	
