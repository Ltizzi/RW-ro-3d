@tool
extends MeshInstance3D

#@export var update_mesh:bool
var chunk_size:int = 16
#@export var threshold :float
#@export var noise_seed : int

#enum BlockType{AIR, DIRT}

var a_mesh := ArrayMesh.new()
var vertices := PackedVector3Array()
var indices := PackedInt32Array()
var uvs := PackedVector2Array()

var face_count := 0
var tex_div := 0.125

var blocks = []

var first_load = true

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	#if update_mesh:
		#init_blocks(16, Vector3i(0,0,0))
		#gen_chunk()
		#update_mesh = false
	pass
		
func init_blocks(size:int, pos: Vector3i):
	#var rng = RandomNumberGenerator.new()
	#
	#var noise = FastNoiseLite.new()
	#noise.seed = noise_seed
	#noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	chunk_size = size
	blocks.resize(chunk_size)
	for x in range(chunk_size):
		blocks[x] = []
		for y in range(chunk_size):
			blocks[x].append([])
			for z in range(chunk_size):
				var block = get_parent().getBlock(Vector3i(pos.x + x , pos.y + y, pos.z + z), first_load)
				blocks[x][y].append(block)
				#if noise.get_noise_3d(x,y,z) >  threshold:
					#blocks[x][y].append(BlockType.DIRT)
				#else:
					#blocks[x][y].append(BlockType.AIR)
	
	first_load = false

func add_uvs(x,y):
	#OLD CODE USING text_div (original was with 0.125
	#uvs.append(Vector2(0,0))
	#uvs.append(Vector2(tex_div,0))
	#uvs.append(Vector2(tex_div,tex_div))
	#uvs.append(Vector2(0,tex_div))
	uvs.append(Vector2(tex_div * x, tex_div * y))
	uvs.append(Vector2(tex_div * x + tex_div, tex_div * y))
	uvs.append(Vector2(tex_div * x + tex_div, tex_div * y +tex_div))
	uvs.append(Vector2(tex_div * x,tex_div * y +tex_div))

func add_triangles():
	#olc colde without facecount *4		
	indices.append(face_count *4 + 0)
	indices.append(face_count *4 + 1)
	indices.append(face_count *4 + 2)
	indices.append(face_count *4 + 0)
	indices.append(face_count *4 + 2)
	indices.append(face_count *4 + 3)
	face_count +=1
	
func gen_cube_mesh(pos: Vector3):
	var is_top_block := false
	
	if block_is_air(pos + Vector3(0,1,0)):
	
		#TOP SIDe
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		
		
		add_triangles()
		#add_uvs(0,0)
		add_uvs(0,1)
		is_top_block = true
	
	if block_is_air(pos + Vector3(1,0,0)):

		#EAST SIDe
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))

		add_triangles()
		#add_uvs(3,0)
		if is_top_block:
			add_uvs(1,1)
		else:
			add_uvs(2,1)
	
	if block_is_air(pos + Vector3(0,0,1)):

		#SOUTH SIDE
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))

		add_triangles()
		#add_uvs(4,0)
		if is_top_block:
			add_uvs(1,1)
		else:
			add_uvs(2,1)
		
	if block_is_air(pos + Vector3(-1,0,0)):

		#WEST SIDe
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))

		add_triangles()
		#add_uvs(5,0)
		if is_top_block:
			add_uvs(1,1)
		else:
			add_uvs(2,1)
	
	if block_is_air(pos + Vector3(0,0,-1)):

		#NORTH SIDe
		vertices.append(pos + Vector3(0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))

		add_triangles()
		#add_uvs(2,0)
		if is_top_block:
			add_uvs(1,1)
		else:
			add_uvs(2,1)
	
	
	if block_is_air(pos + Vector3(0,-1,0)):

		#BOTTOM SIDe
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(0.5, -0.5, 0.5))
		vertices.append(pos + Vector3(0.5, -0.5, -0.5))
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))

		add_triangles()
		#add_uvs(1,0)
		add_uvs(2,1)
		

func gen_chunk():
	a_mesh = ArrayMesh.new()
	vertices = PackedVector3Array()
	indices = PackedInt32Array()
	uvs = PackedVector2Array()
	
	face_count = 0
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			for z in range(chunk_size):
				if(blocks[x][y][z] == Block.BlockType.AIR):
					pass
				else:
					gen_cube_mesh(Vector3(x,y,z))

	if face_count > 0:
		var array = []
		array.resize(Mesh.ARRAY_MAX)
		array[Mesh.ARRAY_VERTEX] = vertices
		array[Mesh.ARRAY_INDEX] = indices
		array[Mesh.ARRAY_TEX_UV] = uvs
		a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
		var trimesh_collisions =  a_mesh.create_trimesh_shape()
		var collision_shape_3d: CollisionShape3D = find_child("StaticBody3D").find_child("CollisionShape3D")
		collision_shape_3d.set_shape(trimesh_collisions)
	mesh = a_mesh
	
func setBlock(local_pos: Vector3i, block_type: Block.BlockType):
	blocks[local_pos.x][local_pos.y][local_pos.z] = block_type

func getBlock(local_pos:Vector3i):
	return blocks[local_pos.x][local_pos.y][local_pos.z]
	

func block_is_air(pos:Vector3):
	if pos.x < 0 or pos.y < 0 or pos.z < 0:
		#return true (para dibujar todo el chunk)
		#
		#de este modo solo dibuja la cara superior
		var block = get_parent().getBlock(pos + position)
		return block == Block.BlockType.AIR
	elif pos.x  >= chunk_size or pos.y >= chunk_size or pos.z >= chunk_size:
		#de este modo solo dibuja la cara superior
		var block = get_parent().getBlock(pos + position)
		return block == Block.BlockType.AIR
	elif blocks[pos.x][pos.y][pos.z] == Block.BlockType.AIR:
		return true
	else:
		return false
		
