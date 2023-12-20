@tool
extends Resource
class_name ProjectSetting


@export var mark_as_advanced:bool=false:
	set(v):
		mark_as_advanced=v
		if ProjectSettings.has_setting(_last_created_at+setting_name):
			remove_setting(_last_created_at)
			create_setting(_last_created_at,true)

@export var setting_name:StringName=&"":
	set(v):
		if ProjectSettings.has_setting(_last_created_at+setting_name):
			remove_setting(_last_created_at)
			create_setting.call_deferred(_last_created_at,true)
		setting_name=v
@export var setting_type:Variant.Type:
	set(value):
		setting_type=value
		
		set(&"setting_default",type_convert(setting_default,value))
		notify_property_list_changed()
		if ProjectSettings.has_setting(_last_created_at+setting_name):
			remove_setting(_last_created_at)
			create_setting(_last_created_at,true)
var setting_default=null:
	set(v):
		setting_default=v
## set to choose a custom scene, the root should have a function
## called "load_setting_data(variable_name:ProjectSetting)"
@export var custom_menu_input:PackedScene



#allows editing whenever neccessary
var _last_created_at:String=""


func _get_property_list():
	return [
		{
			name="setting_default",
			type=setting_type,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _set(property, value):
	set(property,value)





func create_setting(layer_names:String,override_settings:bool=false)->void:
	#skip if it already is generated and not set to override
	if ProjectSettings.has_setting(layer_names+setting_name)&&!override_settings:return
	_last_created_at=layer_names
	ProjectSettings.set_setting(layer_names+setting_name,setting_default)
	ProjectSettings.set_as_basic(layer_names+setting_name,!mark_as_advanced)

func remove_setting(layer_names:String)->void:
	ProjectSettings.set_setting(layer_names+setting_name,null)


func load_menu_input():
	var instanced_input=null
	if custom_menu_input==null:
		instanced_input=preload("res://addons/settingGen/Editor/defaultCustomInputs/base.res").instantiate()
	else:
		instanced_input=custom_menu_input.instantiate()
	
	instanced_input.load_setting_data(self)
	
	return instanced_input

