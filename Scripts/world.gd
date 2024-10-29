@tool
extends Node3D

@export var clear_chunks: bool
@export var generate_chunks: bool
@export var chunk_size:int
@export var world_size: Vector3i

var chunks = {} #Vector3i, chunk (dirección, contenido)

@export var seed:int
@export var noise_frequency: float
var noise

var chunk_prototype = preload("res://Scenes/Chunk.tscn")


func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	if clear_chunks:
		clear_chunks = false
		clearChunks()
	if generate_chunks:
		generate_chunks = false
		generateChunks()
	pass
	
func generateChunks():
	for x in range(world_size.x):
		for y in range(world_size.y):
			for z in range(world_size.z):
				generateChunk(Vector3i(x * chunk_size,y * chunk_size,z * chunk_size))
	
func generateChunk(pos: Vector3i):
	var chunk = chunk_prototype.instantiate()
	chunk.position = pos
	add_child(chunk)
	chunks[pos] = chunk
	chunk.init_blocks(chunk_size, pos, noise)
	
func getBlock(pos:Vector3i):
	if noise.get_noise_3d(pos.x, pos.y, pos.z) > -0.5:
		return Block.BlockType.AIR
	else:
		return Block.BlockType.DIRT

func clearChunks():
	var children = get_children()
	for child in children:
		child.queue_free()
