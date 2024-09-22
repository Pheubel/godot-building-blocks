## A mechanism to handle swiching from one scene to another.
extends Node

## Dictates that the process of switching between scenes and transitions between them has started.
signal scene_switch_process_started
## Sends an update to give an approximation of how much of the scene has been loaded[br]
## [b]percentage[/b] - the current percentage, represented as a number between 0 and 1, of how much of the scene has been loaded.
signal scene_loading(percentage: float)
## Sends an update signalling that the scene is done loading and can be swapped in.
signal scene_finished_loading
## Signals that 
signal scene_switched
## Dictates that the process of switching between scenes and transitions between them has ended.
signal scene_switch_process_completed

## A transition with no efffects, making it appear instant as if no transition took place.
const NO_TRANSITION := preload("res://scene_manager/no_transition/no_transition.tscn")

## A transition that fades to a single color and then to the next scene.
const FADE_OUT_IN_TRANSITION := preload("res://scene_manager/fade_out_in_transition/fade_out_in_transition.tscn")

## The node in charge of transitions between scenes.
@onready var scene_transition_manager := $SceneTransitionManager

## A collection of scene aliases that hold scene paths.
@export var _scenes_aliases: Dictionary
#@export var _scenes: Dictionary[String, String]	# Typed dictionaries are supported in godot 4.4

## The alias of the current scene in use.[br]
## If the current scene does not has an alias, it will be an empty string instead.
var _current_scene_alias: String

## The path leading to the scene that will be loaded
var _loaded_scene_path: String

## An array holding the progress of loading the new scene.
var _progress: Array[float]

## Indicates that the scenes are in progress of being switched.
var _is_switching_scenes: bool

func _ready() -> void:
	_is_switching_scenes = false
	set_process(false)
	var main_scene_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
	
	if Engine.is_editor_hint():
		var current_scene_path := get_tree().current_scene.scene_file_path
		if current_scene_path != main_scene_path:
			print("Starting scene is not the main scene. Current scene alias skipped.")
			return
	
	var path_alias = _scenes_aliases.find_key(main_scene_path)
	if path_alias:
		_current_scene_alias = path_alias
	else:
		_current_scene_alias = ""
		print("No scene alias found for '%s'" % main_scene_path)

func _process(_delta: float) -> void:
	var load_status := ResourceLoader.load_threaded_get_status(_loaded_scene_path, _progress)
	
	if load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		scene_loading.emit(_progress[0])
	
	elif load_status == ResourceLoader.THREAD_LOAD_LOADED:
		scene_finished_loading.emit()
		set_process(false)
	
	elif load_status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Failed to load the resource '%s'" % _loaded_scene_path)
		set_process(false)
	
	elif load_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("Resource '%s' invalid" % _loaded_scene_path)
		set_process(false)

## Switches to the desired scene by it's alias.[br]
## [b]alias[/b] - The alias of the scene you want to load.[br]
## [b]transition[/b] - The transition to use when the scene gets switched.[br]
## [b]transition_arguments[/b] - The arguments to pass to the transition. See the used transition for acceptable arguments.[br]
## [b]use_sub_threads[/b] -  Determines if multiple threads will be used for loading the scene. See [method ResourceLoader.load_threaded_request] for full documentation.
func switch_scene(alias: String, transition: PackedScene = NO_TRANSITION, transition_arguments := Dictionary(), use_sub_threads: bool = false) -> void:
	assert(!is_switching_scenes(), "Cannot switch scenes while a scene is still being loaded.")
	_current_scene_alias = alias
	_switch_to_scene_file(_scenes_aliases[alias], transition, transition_arguments, use_sub_threads)

## Switches to the desired scene by file path.[br]
## [b]file_path[/b] - The path to the scene that should be loaded.[br]
## [b]transition[/b] - The transition to use when the scene gets switched.[br]
## [b]transition_arguments[/b] - The arguments to pass to the transition. See the used transition for acceptable arguments.[br]
## [b]use_sub_threads[/b] -  Determines if multiple threads will be used for loading the scene. See [method ResourceLoader.load_threaded_request] for full documentation.
func switch_scene_from_file(file_path: String, transition: PackedScene = NO_TRANSITION, transition_arguments := Dictionary(), use_sub_threads: bool = false) -> void:
	assert(!is_switching_scenes(), "Cannot switch scenes while a scene is still being loaded.")
	var path_alias = _scenes_aliases.find_key(file_path)
	
	if path_alias:
		_current_scene_alias = path_alias
	else:
		_current_scene_alias = ""
		print("No scene alias found for '%s'" % file_path)
	
	_switch_to_scene_file(file_path, transition, transition_arguments, use_sub_threads)

## Reloads the current scene.
func restart_scene() -> void:
	get_tree().reload_current_scene()

## Shuts down the game.
func quit_game() -> void:
	get_tree().quit()

## Returns the alias of the currently active scene.[br]
## If the scene does not have an alias, an empty string is returned.
func get_current_scene_alias() -> String:
	return _current_scene_alias

## Initiates the transition from scene to scene.[br]
## [b]path_to_scene[/b] - The path to the scene that should be loaded.[br]
## [b]transition[/b] - The transition to use when the scene gets switched.[br]
## [b]transition_arguments[/b] - The arguments to pass to the transition. See the used transition for acceptable arguments.[br]
## [b]use_sub_threads[/b] -  Determines if multiple threads will be used for loading the scene. See [method ResourceLoader.load_threaded_request] for full documentation.
func _switch_to_scene_file(path_to_scene: String, transition: PackedScene, transition_arguments: Dictionary, use_sub_threads: bool) -> void:
	assert(ResourceLoader.exists(path_to_scene), "Target scene does not exist")
	
	_is_switching_scenes = true
	scene_transition_manager.start_transition(transition, transition_arguments)
	
	_loaded_scene_path = path_to_scene
	ResourceLoader.load_threaded_request(path_to_scene, "", use_sub_threads)
	set_process(true)
	
	await scene_transition_manager.pre_switch_phase_finished
	
	if ResourceLoader.load_threaded_get_status(_loaded_scene_path) != ResourceLoader.THREAD_LOAD_LOADED:
		await scene_finished_loading
	
	var loaded_scene := ResourceLoader.load_threaded_get(path_to_scene) as PackedScene
	get_tree().change_scene_to_packed(loaded_scene)
	
	scene_switched.emit()
	scene_transition_manager.finish_transition()
	
	await scene_transition_manager.post_switch_phase_finished
	
	_is_switching_scenes = false
	scene_switch_process_completed.emit()

## Indicates that the scenes are in progress of being switched.
func is_switching_scenes() -> bool:
	return _is_switching_scenes
