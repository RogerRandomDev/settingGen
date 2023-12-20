#needs to be a tool to work properly in the editor
@tool
extends HBoxContainer


#keep these when creating they are needed
signal update_project_setting_value(new_value:Variant)
var setting_resource
func load_setting_data(data):
	setting_resource=data
	$Label.text=data.setting_name+" hase no preset display scene."


#actual functionality would be created for you specific needs

