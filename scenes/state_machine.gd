extends Node
class_name StateMachine
	
var state :int
var previous_state :int
var states :Dictionary = {}
var parent :Node = get_parent()
	
	
func _state_process(delta):
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			_set_state(transition)
	
func _state_logic(delta):
	pass
	
func _get_transition(delta):
	return null
	
func _exit_state(state):
	pass
	
func _enter_state(state):
	pass
	
func _set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		pass
	if state != null:
		pass
		
func _add_state(new_state):
	states[new_state] = states.size
