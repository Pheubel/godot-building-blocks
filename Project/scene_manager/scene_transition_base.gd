extends Node
class_name SceneTransitionBase

signal pre_switch_phase_finished
signal post_switch_phase_finished

var transition_arguments := {}

func start_pre_switch_phase() -> void:
	await get_tree().process_frame
	pre_switch_phase_finished.emit()

func start_post_switch_phase() -> void:
	await get_tree().process_frame
	post_switch_phase_finished.emit()
