extends SceneTransitionBase

const TRANSPARANT := Color(0.0, 0.0, 0.0, 0.0)

func start_pre_switch_phase() -> void:
	var tween := create_tween()
	
	tween.tween_property($".", 'color', transition_arguments.get('color', Color.BLACK), transition_arguments.get('duration', 1.0)).from(TRANSPARANT)
	tween.play()
	
	await tween.finished
	pre_switch_phase_finished.emit()

func start_post_switch_phase() -> void:
	var tween := create_tween()
	
	tween.tween_property($".", 'color', TRANSPARANT, transition_arguments.get('duration', 1.0))
	tween.play()
	
	await tween.finished
	post_switch_phase_finished.emit()
