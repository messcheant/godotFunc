@tool
class_name SoundEntry
extends Resource

@export var name: String = ""
@export var stream: AudioStream
@export var bus: String = "sfx"
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0

func _validate_property(property: Dictionary) -> void:
	if property.name == "bus":
		var buses: PackedStringArray = []
		for i in AudioServer.bus_count:
			buses.append(AudioServer.get_bus_name(i))
		
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(buses)
