## A transition that fades out the old scene into a set color and then fades in the new scene.[br]
## 
## A scene transition called by by the scene transition manager to handle the transition between two scenes
## by making use of a fade out to a set color, folowed by the fade into the new scene over the period of a set
## duration.[br]
## [br]
## Transition arguments:[br]
## [b]color[/b] - ([Color]) The color that the scene will fade out into. Defaults to [const Color.Black].[br]
## [b]duration[b] - ([float]) The duration the full transition, with equal halves being taken by the fade in and out. Defaults to 1 second.
extends SceneTransitionBase

const TRANSPARANT := Color(0.0, 0.0, 0.0, 0.0)

## Starts the transition that happens when the old scene get's swapped out.
func start_pre_switch_phase() -> void:
	var tween := create_tween()
	
	var transition_color := transition_arguments.get('color', Color.BLACK) as Color
	var transition_duration := maxf(transition_arguments.get('duration', 1.0), 0.001) / 2.0
	
	tween.tween_property($".", 'color', transition_color, transition_duration).from(TRANSPARANT)
	tween.play()
	
	await tween.finished
	pre_switch_phase_finished.emit()

## Starts the transition that happens when the new scene gets swapped in.
func start_post_switch_phase() -> void:
	var tween := create_tween()
	
	var transition_duration := maxf(transition_arguments.get('duration', 1.0), 0.001) / 2.0
	
	tween.tween_property($".", 'color', TRANSPARANT, transition_duration)
	tween.play()
	
	await tween.finished
	post_switch_phase_finished.emit()
