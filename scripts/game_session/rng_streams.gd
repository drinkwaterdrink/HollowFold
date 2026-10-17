extends RefCounted
## Gameplay RNGs never use the global/visual RNG. No gameplay draw is needed yet.

const NAMES: Array[String] = ["combat", "loot", "events", "npc"]
var _streams: Dictionary = {}


func _init(seed_value: int) -> void:
	for name in NAMES:
		var rng := RandomNumberGenerator.new()
		# 60 bits avoid signed-overflow/platform ambiguities in textual seed conversion.
		rng.seed = ("%d|%s|i003-v1" % [seed_value, name]).sha256_text().left(15).hex_to_int()
		_streams[name] = rng


func draw(name: String) -> int:
	assert(_streams.has(name), "Only registered gameplay RNG streams may be sampled")
	return _streams[name].randi()


func snapshot() -> Array:
	var result: Array = []
	for name in NAMES:
		var rng: RandomNumberGenerator = _streams[name]
		result.append([name, str(rng.seed), str(rng.state)])
	return result
