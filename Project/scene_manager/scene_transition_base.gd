extends Node
class_name SceneTransitionBase

signal pre_switch_phase_finished
signal post_switch_phase_finished

var transition_arguments := {}

func start_pre_switch_phase() -> void:
	pre_switch_phase_finished.emit()

func start_post_switch_phase() -> void:
	post_switch_phase_finished.emit()
