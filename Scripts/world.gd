@tool
extends Node3D

@export var clear_chunks: bool
@export var generate_chunks: bool
@export var chunk_size:int
@export var world_size: Vector3i

var chunks = {} #Vector3i, chunk (dirección, contenido)

@export var seed:int
@export var noise_frequency: float
@export var cave_noise_freq:float
var noise
var cave_noise


var chunk_prototype = preload("res://Scenes/Chunk.tscn")


func _ready() -> void:
	generate_chunks = true
	#print("generating...")
	#noise = FastNoiseLite.new()
	#noise.seed = seed
	#noise.frequency = noise_frequency
	#generateChunks()
	pass # Replace with function body.



func _process(delta: float) -> void:

	if clear_chunks:
		clear_chunks = false
		clearChunks()
	if generate_chunks:
		generate_chunks = false
		noise = FastNoiseLite.new()
		noise.seed = seed
		noise.frequency = noise_frequency
		cave_noise = FastNoiseLite.new()
		cave_noise.seed = seed
		cave_noise.frequency = cave_noise_freq
		generateChunks()
	pass
	
func generateChunks():
	clearChunks()
	for x in range(world_size.x):
		for y in range(world_size.y):
			for z in range(world_size.z):
				generateChunk(Vector3i(x * chunk_size,y * chunk_size,z * chunk_size))
				
				await Engine.get_main_loop().process_frame
	
func generateChunk(pos: Vector3i):
	var chunk = chunk_prototype.instantiate()
	chunk.position = pos
	add_child(chunk)
	chunks[pos] = chunk
	chunk.init_blocks(chunk_size, pos)
	chunk.gen_chunk()
	
func getBlock(pos:Vector3i):
	#if noise.get_noise_3d(pos.x, pos.y, pos.z) > 0:
	var n =( noise.get_noise_2d(pos.x,  pos.z) + 1) * chunk_size
	if n > pos.y:
		var cave_n = cave_noise.get_noise_3d(pos.x, pos.y, pos.z)
		if cave_n > -0.5:
			return Block.BlockType.DIRT
		else:
			return Block.BlockType.AIR
	else:
		return Block.BlockType.AIR

func clearChunks():
	var children = get_children()
	for child in children:
		child.queue_free()
