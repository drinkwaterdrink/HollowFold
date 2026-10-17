extends RefCounted
## Pure validation and arithmetic. Only the session applies damage/resources/death.

const Sight = preload("res://scripts/game_session/visibility.gd")
const Status = preload("res://scripts/combat/status_effects.gd")

static func validate(grid: RefCounted, attacker: RefCounted, target: RefCounted) -> String:
	if attacker == null or not attacker.alive:
		return "ACTOR_DEAD"
	if target == null or not target.alive or target.id == attacker.id:
		return "TARGET_UNAVAILABLE"
	var delta: Vector2i = target.cell - attacker.cell
	if maxi(absi(delta.x), absi(delta.y)) > attacker.attack_range:
		return "OUT_OF_RANGE"
	if not Sight.has_line(grid, attacker.cell, target.cell):
		return "OBSTRUCTED"
	if attacker.stamina < attacker.stamina_cost:
		return "INSUFFICIENT_STAMINA"
	return "OK"

static func damage(attacker: RefCounted, target: RefCounted) -> int:
	var raw: int = maxi(0, attacker.offense - maxi(0, target.armor - attacker.penetration) - target.shield)
	var resistance: int = clampi(int(target.resistances.get(attacker.damage_type, 0)), -100, 100)
	return floori(float(raw * (100 - resistance)) / 100.0)

static func resolve(attacker: RefCounted, target: RefCounted, roll: int) -> Dictionary:
	var chance: int = clampi(attacker.accuracy - target.evasion - Status.evasion_bonus(target), 5, 95)
	var hit: bool = roll < chance
	return {"hit": hit, "roll": roll, "chance": chance, "damage": damage(attacker, target) if hit else 0,
		"damage_type": attacker.damage_type}
