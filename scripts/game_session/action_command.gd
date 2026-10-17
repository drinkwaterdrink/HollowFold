extends RefCounted
## Request IDs identify a single intent; actors, directions and targets are explicit.

enum Kind { MOVE, WAIT, INSPECT }
var request_id: int = 0
var actor_id: String = "player"
var kind: int = Kind.WAIT
var direction: Vector2i = Vector2i.ZERO
var target: Vector2i = Vector2i.ZERO


static func move(id: int, delta: Vector2i) -> RefCounted:
	var command = load("res://scripts/game_session/action_command.gd").new()
	command.request_id = id
	command.kind = Kind.MOVE
	command.direction = delta
	return command


static func wait(id: int) -> RefCounted:
	var command: RefCounted = move(id, Vector2i.ZERO)
	command.kind = Kind.WAIT
	return command


static func inspect(id: int, cell: Vector2i) -> RefCounted:
	var command: RefCounted = wait(id)
	command.kind = Kind.INSPECT
	command.target = cell
	return command


static func from_record(item: Dictionary) -> RefCounted:
	var command: RefCounted = wait(int(item["id"]))
	command.kind = int(item["kind"])
	if item.has("direction"):
		command.direction = Vector2i(int(item["direction"][0]), int(item["direction"][1]))
	if item.has("target"):
		command.target = Vector2i(int(item["target"][0]), int(item["target"][1]))
	return command
