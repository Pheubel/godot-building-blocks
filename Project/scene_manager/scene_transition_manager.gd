extends CanvasLayer

signal pre_switch_phase_finished
signal post_switch_phase_finished

var _is_playing_transition: bool = false
var _transition_node: SceneTransitionBase

func is_playing_transtition() -> bool:
	return _is_playing_transition

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
	
func finish_transition() -> void:
	_transition_node.start_post_switch_phase()
	await _transition_node.post_switch_phase_finished
	post_switch_phase_finished.emit()
	
	_transition_node.queue_free()
	
	_is_playing_transition = false
