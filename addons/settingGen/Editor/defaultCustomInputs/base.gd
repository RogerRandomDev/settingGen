#needs to be a tool to work properly in the editor
@tool
extends HBoxContainer


#keep these when creating they are needed
signal update_project_setting_value(new_value:Variant)
var setting_resource

func _ready():load_setting_data(setting_resource)

func load_setting_data(data):
	$Label.text=data.setting_name+" currently no preset display scene for %s. You can add you own by adding to the ProjectSetting class get_default_display_for_input function"%type_string(data.setting_type)


#actual functionality would be created for you specific needs

