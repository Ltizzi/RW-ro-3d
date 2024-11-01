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
var chunks_target_for_regen = []

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
	#chunks_target_for_regen != null:
	for chunk in chunks_target_for_regen:
		chunk.gen_chunk()
	chunks_target_for_regen.clear()
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
	
func getBlock(pos:Vector3i, from_noise = false):

	if pos.x < 0 or pos.y < 0 or pos.z <0 or pos.x >= world_size.x * chunk_size or pos.y >= world_size.y * chunk_size or pos.z >= world_size.z * chunk_size:
		return Block.BlockType.AIR

	#if noise.get_noise_3d(pos.x, pos.y, pos.z) > 0:
	if not from_noise:
		var chunk_pos = worldPositionToChunkPos(pos)
		var local_pos = pos - chunk_pos
		if chunks.has(chunk_pos):
			return chunks[chunk_pos].getBlock(local_pos)
		
	var n =( noise.get_noise_2d(pos.x,  pos.z) + 1) * chunk_size
	if n > pos.y:
		var cave_n = cave_noise.get_noise_3d(pos.x, pos.y, pos.z)
		if cave_n > -0.5:
			return Block.BlockType.DIRT
		else:
			return Block.BlockType.AIR
	else:
		return Block.BlockType.AIR
		
func setBlockByWorldPosition(pos:Vector3i, block_type: Block.BlockType):
	var chunk_pos = worldPositionToChunkPos(pos)
	var local_pos =  pos - chunk_pos
	if chunks.has(chunk_pos):
		chunks[chunk_pos].setBlock(local_pos, block_type)
		chunks_target_for_regen.append(chunks[chunk_pos])
		#chunks[chunk_pos].gen_chunk()
	var adjacent_chunks = blockIsOnEdgeOfChunk(local_pos)
	for adjacent_chunk in adjacent_chunks:
		var ac_pos  = chunk_pos +  adjacent_chunk * chunk_size
		if chunks.has(ac_pos):
			chunks_target_for_regen.append(chunks[ac_pos])
	
func blockIsOnEdgeOfChunk(pos: Vector3i):
	var edges = []
	if pos.x == 0:
		edges.append(Vector3i(-1,0,0))
	if pos.y == 0:
		edges.append(Vector3i(0,-1,0))
	if pos.z == 0:
		edges.append(Vector3i(0,0,-1))
	if pos.x >= chunk_size - 1:
		edges.append(Vector3i(1,0,0))
	if pos.y >= chunk_size - 1:
		edges.append(Vector3i(0,1,0))
	if pos.z >= chunk_size - 1:
		edges.append(Vector3i(0,0,1))
	
	return edges

func worldPositionToChunkPos(pos: Vector3i):
	return (pos / chunk_size) * chunk_size

func clearChunks():
	var children = get_children()
	for child in children:
		child.queue_free()
