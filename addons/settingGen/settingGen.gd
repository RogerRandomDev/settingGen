@tool
extends EditorPlugin

const setting_editor=preload("res://addons/settingGen/Editor/ProjectSettingEditor.tscn")
var instance_setting_editor

func _enter_tree():
	instance_setting_editor=setting_editor.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(instance_setting_editor)
	#add_control_to_container()
	_make_visible(false)

func _has_main_screen():return true


func _get_plugin_name():return "SettingGen"


func _make_visible(visible):
	instance_setting_editor.visible=visible

func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
