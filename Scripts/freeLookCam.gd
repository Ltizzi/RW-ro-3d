extends Camera3D

@export_range(0.0, 1.0) var sensitivity:float = 0.25
@export_range(5, 28) var cam_speed: float
@export_range(2,10) var cam_speed_multiplier: float

@onready var world: Node3D = $"../World"


var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

var velocity :Vector3


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	get_inputs()
	apply_movements(delta)
		
	pass
	
func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	if event.is_action_pressed("click"):
		raycast_from_mouse_pos()
		pass

func get_inputs():
	if Input.is_action_pressed("cam_toggle_mouselook"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_pressed("cam_left"):
		velocity.x = -1
	elif Input.is_action_pressed("cam_right"):
		velocity.x = 1
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("cam_up"):
		velocity.y = 1
	elif Input.is_action_pressed("cam_down"):
		velocity.y = -1
	else:
		velocity.y = 0
	
	if Input.is_action_pressed("cam_forward"):
		velocity.z = -1
	elif Input.is_action_pressed("cam_back"):
		velocity.z = 1
	else:
		velocity.z = 0
	

func raycast_from_mouse_pos():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from 
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	#print(raycast_result)
	if len(raycast_result) > 0:
		var hit_pos = raycast_result.position - (raycast_result.normal * 0.5)
		
		hit_pos = Vector3i(round(hit_pos.x), round(hit_pos.y), round(hit_pos.z))
		
		if Input.is_action_pressed("add_block"):
			hit_pos += Vector3i(raycast_result.normal)
			world.setBlockByWorldPosition(hit_pos, Block.BlockType.DIRT)
		else:
			world.setBlockByWorldPosition(hit_pos, Block.BlockType.AIR)


	
func apply_movements(delta:float):
	var speed_multiply = 1
	if Input.is_action_pressed("cam_speed_multiplier"):
		speed_multiply = cam_speed_multiplier
	
	translate(velocity * delta * cam_speed * speed_multiply)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0,0)
		
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch +=pitch
		
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
