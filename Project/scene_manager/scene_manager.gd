extends Node

signal scene_switch_process_started
signal scene_loading(percentage: float)
signal scene_finished_loading
signal scene_switched
signal scene_switch_process_completed

const DEFAULT_TRANSITION := preload("res://scene_manager/fade_out_in_transition/fade_out_in_transition.tscn")

@onready var scene_transition_manager := $SceneTransitionManager

@export var _scenes_aliases: Dictionary
#@export var _scenes: Dictionary[String, String]	# Typed dictionaries are supported in godot 4.4
var _current_scene_alias: String
var _loaded_scene_path: String
var _progress: Array[float]
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

func switch_scene(alias: String, transition: PackedScene = DEFAULT_TRANSITION, transition_arguments: Dictionary = {}, use_sub_threads: bool = false) -> void:
	assert(!is_switching_scenes(), "Cannot switch scenes while a scene is still being loaded.")
	_current_scene_alias = alias
	_switch_to_scene_file(_scenes_aliases[alias], transition, transition_arguments, use_sub_threads)

func switch_scene_from_file(file_path: String, transition: PackedScene = DEFAULT_TRANSITION, transition_arguments: Dictionary = {}, use_sub_threads: bool = false) -> void:
	assert(!is_switching_scenes(), "Cannot switch scenes while a scene is still being loaded.")
	var path_alias = _scenes_aliases.find_key(file_path)
	
	if path_alias:
		_current_scene_alias = path_alias
	else:
		_current_scene_alias = ""
		print("No scene alias found for '%s'" % file_path)
	
	_switch_to_scene_file(file_path, transition, transition_arguments, use_sub_threads)

func restart_scene() -> void:
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().quit()

func get_current_scene_alias() -> String:
	return _current_scene_alias

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

func is_switching_scenes() -> bool:
	return _is_switching_scenes
