# This is an example of an application _config. 
# In order to make it globally accessible you would add it as an autoload.

## A node for keeping track of settings that can be changed by the player.
extends Node

enum WINDOW_MODE {
	## Allows the window to be displayed with borders and title bars,
	## making it resizable and movable within the screen's boundaries.
	WINDOWED,
	
	## Enables fullscreen display without borders or title bars,
	## but allows for easier transitioning between other windows and desktop access.
	BORDERLESS_FULLSCREEN,
	
	## Enables fullscreen display by making use of native fullscreen functionality,
	## but can lead to stutters or blinking depending on the platform.
	EXCLUSIVE_FULLSCREEN
}

const CONFIG_FILE := "user://config.cfg"

#region _config sections
const AUDIO_SECTION := "Audio Volume"
const GRAPHIC_SECTION := "Graphic Settings"
#endregion

@export_range(0.0,1.0) var default_volume := 1.0
@export var default_window_mode := WINDOW_MODE.WINDOWED
@export var default_window_size := Vector2i(1280, 720)
@export var default_vsync_mode := DisplayServer.VSYNC_MAILBOX

var _config := ConfigFile.new()

func _ready() -> void:
	load_config()

## Loads the current settings from the _config file and applies it to the game.[br]
func load_config() -> void:
	var error := _config.load(CONFIG_FILE)
	
	if error != OK:
		print("Unable to read '%s'. Creating new config file with default values." % CONFIG_FILE)
		_populate_config()
		
		save_config()
	else:
		_apply_loaded_config()

## Sets up the default settings for the _config file. [br]
## [br]
## When overriding, make sure to call [code]super._create_default()[/code] at some point in the fucntion.
func _populate_config() -> void:
	var buses := AudioHelper.get_audio_bus_names()
	for bus_name in buses:
		set_bus_volume(bus_name, default_volume)
	
	set_window_mode(default_window_mode)
	set_window_resolution(default_window_size)
	
	set_vsync_mode(default_vsync_mode)

## Applies the _configuration settings present to the game.
## [br]
## When overriding, make sure to call [code]super._create_default()[/code] at some point in the fucntion.
func _apply_loaded_config():
	var buses := AudioHelper.get_audio_bus_names()
	for bus_name in buses:
		var volume := get_bus_volume(bus_name)
		AudioHelper.set_linear_bus_volume_by_name(bus_name, volume)
	
	var window_mode := get_window_mode()	
	if window_mode == WINDOW_MODE.BORDERLESS_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif window_mode == WINDOW_MODE.WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif window_mode == WINDOW_MODE.EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	var window_resolution := get_window_resolution()
	DisplayServer.window_set_size(window_resolution)
	
	var vsync_mode := get_vsync_mode()
	DisplayServer.window_set_vsync_mode(vsync_mode)

## Saves the currently applied _configurations to the _config file.
func save_config() -> void:
	_config.save(CONFIG_FILE)

## Returns the linear volume of the given audio bus.[br]
## [b]bus_name[/b] - The name of the bus in the audio server.
func get_bus_volume(bus_name: String) -> float:
	return _config.get_value(AUDIO_SECTION, bus_name, default_volume)

## Sets the linear volume of the given audio bus.[br]
## [b]bus_name[/b] - The name of the bus in the audio server.[br]
## [b]volume[/b] - The desired linear volume for the given audio bus.
func set_bus_volume(bus_name: String, volume: float) -> void:
	AudioHelper.set_linear_bus_volume_by_name(bus_name, volume)
	_config.set_value(AUDIO_SECTION, bus_name, volume)

## Gets the currently selected window mode.
func get_window_mode() -> WINDOW_MODE:
	return _config.get_value(GRAPHIC_SECTION, "window_mode", default_window_mode)

## Sets the window mode.[br]
## [b]window_mode[/b] - The desired window mode. See [enum WINDOW_MODE]
func set_window_mode(window_mode: WINDOW_MODE) -> void:
	_config.set_value(GRAPHIC_SECTION, "window_mode", window_mode)
	
	if window_mode == WINDOW_MODE.BORDERLESS_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif window_mode == WINDOW_MODE.WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif window_mode == WINDOW_MODE.EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

## Gets the currently active window resolution.[br]
## [br]
## Window resolution will be ignored outside of WINDOW_MODE.WINDOWED
func get_window_resolution() -> Vector2i:
	return Vector2i(
			_config.get_value(GRAPHIC_SECTION, "window_width", default_window_size.x),
			_config.get_value(GRAPHIC_SECTION, "window_height", default_window_size.y)
	)

## Sets the currently active window resolution.[br]
## [b]window_resolution[/b] - The desired window resolution.
## [br]
## Window resolution will be ignored outside of WINDOW_MODE.WINDOWED
func set_window_resolution(window_resolution: Vector2i) -> void:
	_config.set_value(GRAPHIC_SECTION, "window_width", window_resolution.x)
	_config.set_value(GRAPHIC_SECTION, "window_height", window_resolution.y)
	
	DisplayServer.window_set_size(window_resolution)

## Returns the currently selected VSync mode.
func get_vsync_mode() -> DisplayServer.VSyncMode:
	return _config.get_value(GRAPHIC_SECTION, "vsync_mode", default_vsync_mode)

## Sets the currently active VSync mode.
## [b]vsync_mode[/b] - The VSync option to handle displaying incomplete frames.
func set_vsync_mode(vsync_mode: DisplayServer.VSyncMode) -> void:
	_config.set_value(GRAPHIC_SECTION, "vsync_mode", vsync_mode)
	DisplayServer.window_set_vsync_mode(vsync_mode)
