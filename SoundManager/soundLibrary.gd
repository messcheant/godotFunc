class_name SoundLibrary
extends Resource

@export var entries: Array[SoundEntry] = []

func get_sound(sound_name: String) -> SoundEntry:
	for entry in entries:
		if entry.name == sound_name:
			return entry
	push_warning("SoundLibrary: '%s' tidak ditemukan" % sound_name)
	return null
