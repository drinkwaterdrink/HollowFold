extends RefCounted
## Integer logical readiness, cost/speed profiles, deterministic ties, bounded preview.

const MAX_READY_EVENTS: int = 64
var time: int = 0
var _actors: Dictionary = {}


func add_actor(id: String, action_cost: int = 100, speed: int = 100) -> bool:
	if id.is_empty() or _actors.has(id) or action_cost < 1 or action_cost > 10000 or speed < 1 or speed > 10000:
		return false
	var period: int = maxi(1, ceili(float(action_cost) * 100.0 / float(speed)))
	_actors[id] = {"cost": action_cost, "speed": speed, "period": period, "next": time + period}
	return true


func preview(elapsed: int) -> Dictionary:
	if elapsed <= 0 or elapsed > 1000000:
		return {"ok": false}
	var next_actors: Dictionary = _actors.duplicate(true)
	var ready: Array[Dictionary] = []
	var ids: Array = next_actors.keys()
	ids.sort()
	var end_time: int = time + elapsed
	while true:
		var selected: String = ""
		var due: int = end_time + 1
		for id: String in ids:
			if next_actors[id]["next"] < due:
				selected = id
				due = next_actors[id]["next"]
		if selected.is_empty():
			break
		if ready.size() == MAX_READY_EVENTS:
			return {"ok": false}
		ready.append({"actor_id": selected, "time": due})
		next_actors[selected]["next"] += next_actors[selected]["period"]
	return {"ok": true, "time": end_time, "actors": next_actors, "ready": ready}


func commit(plan: Dictionary) -> void:
	assert(plan.get("ok", false), "Only a successful bounded plan may commit")
	time = plan["time"]
	_actors = plan["actors"].duplicate(true)


func snapshot() -> Array:
	var records: Array = []
	var ids: Array = _actors.keys()
	ids.sort()
	for id: String in ids:
		var actor: Dictionary = _actors[id]
		records.append([id, actor["cost"], actor["speed"], actor["period"], actor["next"]])
	return [time, records]
