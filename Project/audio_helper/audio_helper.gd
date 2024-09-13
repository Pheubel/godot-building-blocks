class_name AudioHelper

## Returns the linear representation of the volume of the given bus.[br]
## [br]
## [b]bus_index[/b] - The index of the bus in the audio server.
static func get_linear_bus_volume(bus_index: int) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

## Returns the linear representation of the volume of the given bus.[br]
##
## [b]bus_name[/b] - The name of the bus in the audio server.
static func get_linear_bus_volume_by_name(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	assert(bus_index >= 0)
	
	return get_linear_bus_volume(bus_index)

## Sets the volume of the given bus using a linear value.[br]
## [br]
## [b]bus_index[/b] - The index of the bus in the audio server.
## [b]volume[/b] - The linear representation of the desired volume.
static func set_linear_bus_volume(bus_index: int, volume: float) -> void:
	var volume_db := linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

## Sets the volume of the given bus using a linear value.[br]
## [br]
## [b]bus_name[/b] - The name of the bus in the audio server.
## [b]volume[/b] - The linear representation of the desired volume.
static func set_linear_bus_volume_by_name(bus_name: StringName, volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	assert(bus_index >= 0)
	
	set_linear_bus_volume(bus_index, volume)

## Returns a collection of audio bus names in the order they appear in the audio server.
static func get_audio_bus_names() -> PackedStringArray:
	var buses := PackedStringArray()
	buses.resize(AudioServer.bus_count)
	
	for bus_index in AudioServer.bus_count:
		buses[bus_index] = AudioServer.get_bus_name(bus_index)
	
	return buses
