extends RefCounted
## Shared mutable data. Instances stay private to SimulationSession.

var id: String = "player"
var name: String = "Explorer"
var cell: Vector2i = Vector2i.ZERO
var max_hp: int = 30
var hp: int = 30
var max_stamina: int = 12
var stamina: int = 12
var offense: int = 7
var accuracy: int = 85
var evasion: int = 10
var armor: int = 1
var penetration: int = 0
var shield: int = 0
var resistances: Dictionary = {"physical": 0}
var damage_type: String = "physical"
var attack_range: int = 1
var attack_cost: int = 100
var stamina_cost: int = 3
var speed: int = 100
var alive: bool = true
var ai: String = "none"
var detection: int = 6
var behavior: String = "idle"
var statuses: Array[Dictionary] = []

func snapshot() -> Dictionary:
	var resistance_records: Array = []
	var keys: Array = resistances.keys()
	keys.sort()
	for key: String in keys:
		resistance_records.append([key, resistances[key]])
	return {"id": id, "name": name, "cell": [cell.x, cell.y], "max_hp": max_hp, "hp": hp,
		"max_stamina": max_stamina, "stamina": stamina, "offense": offense, "accuracy": accuracy,
		"evasion": evasion, "armor": armor, "penetration": penetration, "shield": shield,
		"resistances": resistance_records, "damage_type": damage_type, "attack_range": attack_range,
		"attack_cost": attack_cost, "stamina_cost": stamina_cost, "speed": speed, "alive": alive,
		"ai": ai, "detection": detection, "behavior": behavior, "statuses": statuses.duplicate(true)}

static func from_spec(spec: Dictionary) -> RefCounted:
	var actor: RefCounted = load("res://scripts/combat/actor_state.gd").new()
	for field: String in ["id", "name", "max_hp", "max_stamina", "offense", "accuracy", "evasion", "armor",
		"penetration", "shield", "damage_type", "attack_range", "attack_cost", "stamina_cost", "speed", "ai", "detection"]:
		if spec.has(field):
			actor.set(field, spec[field])
	actor.max_hp = clampi(actor.max_hp, 1, 10000)
	actor.hp = clampi(int(spec.get("hp", actor.max_hp)), 0, actor.max_hp)
	actor.max_stamina = clampi(actor.max_stamina, 0, 1000)
	actor.stamina = clampi(int(spec.get("stamina", actor.max_stamina)), 0, actor.max_stamina)
	actor.offense = clampi(actor.offense, 0, 10000)
	actor.armor = clampi(actor.armor, 0, 10000)
	actor.penetration = clampi(actor.penetration, 0, 10000)
	actor.shield = clampi(actor.shield, 0, 10000)
	actor.accuracy = clampi(actor.accuracy, 0, 200)
	actor.evasion = clampi(actor.evasion, 0, 200)
	actor.attack_range = clampi(actor.attack_range, 1, 12)
	actor.attack_cost = clampi(actor.attack_cost, 1, 10000)
	actor.stamina_cost = clampi(actor.stamina_cost, 0, 1000)
	actor.speed = clampi(actor.speed, 1, 10000)
	actor.detection = clampi(actor.detection, 0, 12)
	actor.cell = Vector2i(int(spec["cell"][0]), int(spec["cell"][1]))
	if spec.has("resistances"):
		actor.resistances = {}
		for key: String in spec["resistances"]:
			actor.resistances[key] = clampi(int(spec["resistances"][key]), -100, 100)
	actor.alive = actor.hp > 0
	return actor
