@tool
extends HBoxContainer


var setting_resource

func load_setting_data(data):
	setting_resource=data
	$Label.text=data.setting_name+" hase no preset display scene."
	
