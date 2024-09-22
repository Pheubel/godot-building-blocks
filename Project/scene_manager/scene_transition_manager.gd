## A mechanism in charge of handling transitions between scenes.
extends CanvasLayer

## Signals that the transition before the scene has switched has completed.
signal pre_switch_phase_finished

## Signals that the transition after the scene has switched has completed.
signal post_switch_phase_finished

## Dictates wether the scene transition manager is currently in a transition.
var _is_playing_transition: bool = false

## The current transition in use.
var _transition_node: SceneTransitionBase

## Returns wether the scene transition manager is currently in a transition.
func is_playing_transtition() -> bool:
	return _is_playing_transition

## Creates the transition with the given arguments and plays the pre switch transition.[br]
## [b]transition_scene[/b] - The transition that will be played during the scene switching process. Must inherit from [SceneTransitionBase].[br]
## [b]transition_arguments[/b] - The arguments given to the transition. valid arguments will differ from transition to transition.
func start_transition(transition_scene: PackedScene, transition_arguments: Dictionary) -> void:
	assert(!is_playing_transtition(), "Cannot play a transition while one is already playing.")
	
	_transition_node = transition_scene.instantiate() as SceneTransitionBase
	assert(_transition_node, "Transition scenes must inherit from 'SceneTransitionBase'.")
	_transition_node.transition_arguments.merge(transition_arguments, true)
	
	_is_playing_transition = true
	
	add_child(_transition_node)
	
	_transition_node.start_pre_switch_phase()
	await _transition_node.pre_switch_phase_finished
	pre_switch_phase_finished.emit()

## Plays the post switch animation and cleans up the transition.
func finish_transition() -> void:
	_transition_node.start_post_switch_phase()
	await _transition_node.post_switch_phase_finished
	post_switch_phase_finished.emit()
	
	_transition_node.queue_free()
	_transition_node = null
	
	_is_playing_transition = false
