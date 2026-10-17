extends RefCounted
## Stable codes and detached event payloads; no scene objects or animation references.

var request_id: int = 0
var code: String = "OK"
var success: bool = true
var cost: int = 0
var action_index: int = 0
var time: int = 0
var from_cell: Vector2i = Vector2i.ZERO
var to_cell: Vector2i = Vector2i.ZERO
var inspection: Dictionary = {}
var events: Array[Dictionary] = []


func record() -> Dictionary:
	return {"request_id": request_id, "code": code, "success": success, "cost": cost,
		"action_index": action_index, "time": time,
		"from": [from_cell.x, from_cell.y], "to": [to_cell.x, to_cell.y],
		"inspection": inspection.duplicate(true), "events": events.duplicate(true)}
