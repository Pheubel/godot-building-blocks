## The base class for scene transitions. If used unaltered, it will act as if there is no actual transition.
extends Node
class_name SceneTransitionBase

## Signals that the transition before the scene has switched has completed.
signal pre_switch_phase_finished

## Signals that the transition after the scene has switched has completed.
signal post_switch_phase_finished

## The arguments given to the transition. valid arguments will differ from transition to transition.
var transition_arguments := {}

## Starts the transition that happens when the old scene get's swapped out.
func start_pre_switch_phase() -> void:
	await get_tree().process_frame
	pre_switch_phase_finished.emit()

## Starts the transition that happens when the new scene gets swapped in.
func start_post_switch_phase() -> void:
	await get_tree().process_frame
	post_switch_phase_finished.emit()
