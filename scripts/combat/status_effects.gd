extends RefCounted
## Bounded shared status interface. No reactive chains or full status catalogue.

const MAX_STATUSES: int = 8
const MAX_DURATION: int = 100

static func apply(actor: RefCounted, id: String, duration: int, stacking: String = "refresh") -> bool:
	if id != "guarded" or duration < 1 or duration > MAX_DURATION or stacking not in ["refresh", "replace", "ignore"]:
		return false
	for status: Dictionary in actor.statuses:
		if status["id"] == id:
			if stacking != "ignore":
				status["duration"] = maxi(status["duration"], duration) if stacking == "refresh" else duration
				status["stacking"] = stacking
			return true
	if actor.statuses.size() >= MAX_STATUSES:
		return false
	actor.statuses.append({"id": id, "duration": duration, "stacking": stacking, "tags": ["defense"], "priority": 0})
	return true

static func tick(actor: RefCounted) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for index in range(actor.statuses.size() - 1, -1, -1):
		actor.statuses[index]["duration"] -= 1
		if actor.statuses[index]["duration"] <= 0:
			events.append({"type": "status_removed", "actor_id": actor.id, "status_id": actor.statuses[index]["id"]})
			actor.statuses.remove_at(index)
	return events

static func evasion_bonus(actor: RefCounted) -> int:
	for status: Dictionary in actor.statuses:
		if status["id"] == "guarded":
			return 10
	return 0
