extends Button
#class_name FoxButton
#public_api

# Workaround Godot Engine bugs
var on_pressed_instance = null
var on_pressed_method_name = null
var was_button_pressed = false

func _process(_delta):
	var is_pressed = self.pressed
	var was_pressed = self.was_button_pressed
	if is_pressed != was_pressed:
		self.was_button_pressed = is_pressed
		var action_mode_state = (self.action_mode == 0)
		if is_pressed == action_mode_state:
			self._on_FoxButton_pressed() 
	
	# ._process(_delta)

func connect_on_pressed(instance, method_name):
	self.on_pressed_instance = instance
	self.on_pressed_method_name = method_name

func _on_FoxButton_pressed():
	if self.on_pressed_instance != null:
		self.on_pressed_instance.call(self.on_pressed_method_name)

