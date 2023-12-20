@tool
extends Resource
class_name ProjectSettingList

#made just in case you experience issues from settings changing
#shouldn't cause issues but just in case it does it is here now.
const autoclear_removed_settings:bool=true
var is_root = false

@export_placeholder("Placeholder") var layer_name:String:
	set(v):
		layer_name=v
		#update the path of the sub_lists
		for list in sub_lists:
			list._true_path=_true_path+"%s/"%layer_name
			#have to do this to ensure they are properly ordered still
			list.clear_project_settings()
			list.generate_project_settings()
		#updates path for the settings_list
		for setting in settings_list:
			setting._last_created_at=_true_path+"%s/"%layer_name
			setting.setting_name=setting.setting_name+""

@export var settings_list:Array[ProjectSetting]:
	set(updated_list):
		#region autoclear
		if autoclear_removed_settings&&(is_root||_true_path!=""):
			var removed_settings=settings_list.filter(func(a):return !updated_list.has(a))
			for setting in removed_settings:
				setting.remove_setting(_true_path+"%s/"%layer_name)
		#endregion
		
		if(len(updated_list)&&updated_list[len(updated_list)-1]==null):
			var new_setting=ProjectSetting.new()
			new_setting._last_created_at=_true_path+"%s/"%layer_name
			updated_list[len(updated_list)-1]=new_setting
		settings_list=updated_list

@export var sub_lists:Array[ProjectSettingList]:
	set(updated_list):
		#region autoclear
		if autoclear_removed_settings&&(is_root||_true_path!=""):
			var removed_lists=sub_lists.filter(func(a):return !updated_list.has(a))
			for list in removed_lists:list.clear_project_settings()
		#endregion
		
		if(len(updated_list)&&updated_list[len(updated_list)-1]==null):
			updated_list[len(updated_list)-1]=ProjectSettingList.new()
		
		#update the path of the sub_lists
		for list in updated_list:
			list._true_path=_true_path+"%s/"%layer_name
		#region autoadd
		if autoclear_removed_settings&&(is_root||_true_path!=""):
			var added_lists=updated_list.filter(func(a):return !sub_lists.has(a))
			for list in added_lists:list.generate_project_settings.call_deferred()
		#endregion
		sub_lists=updated_list

var _true_path:String=""


@export_category("Debug Tools")
var generate:bool=false:
	set(v):
		generate_project_settings()

var clear_current:bool=false:
	set(v):
		clear_project_settings()


func _init():
	generate_true_paths()

func _get_property_list():
	if _true_path!="":return []
	return [
		{
			name="generate",
			type=TYPE_BOOL
		},
		{
			name="clear_current",
			type=TYPE_BOOL
		}
	]


#call with nothing to initiate the base generation structure and layout
func generate_project_settings()->void:
	
	for setting in settings_list:
		setting.create_setting(_true_path+"%s/"%layer_name)
	for layer in sub_lists:
		layer.generate_project_settings()
#call with nothing to initiate the base clear
func clear_project_settings()->void:
	for setting in settings_list:
		setting.remove_setting(_true_path+"%s/"%layer_name)
	for layer in sub_lists:
		layer.clear_project_settings()


#get the settings list at the path provided
func get_settings_at_path(setting_path:String):
	setting_path=setting_path.trim_prefix("/")
	if setting_path.trim_suffix("/")==layer_name:return settings_list
	var next_layer_name=setting_path.split("/")[1].trim_suffix("/")
	
	
	for list in sub_lists:
		if list.layer_name!=next_layer_name:continue
		
		var target_string=setting_path.trim_prefix(setting_path.split("/")[0])
		var settings_in_layer=list.get_settings_at_path(target_string)
		
		if settings_in_layer:return settings_in_layer
	return null


func traverse_to(setting_path:String):
	setting_path=setting_path.trim_prefix("/")
	if setting_path.trim_suffix("/")==layer_name:return self
	var next_layer_name=setting_path.split("/")[1].trim_suffix("/")
	for list in sub_lists:
		if list.layer_name!=next_layer_name:continue
		
		var target_string=setting_path.trim_prefix(setting_path.split("/")[0])
		var settings_in_layer=list.traverse_to(target_string)
		
		if settings_in_layer:return settings_in_layer
	return null

func generate_true_paths():
	for list in sub_lists:
		list._true_path=_true_path.trim_suffix("/")+"/%s"%layer_name
		list.generate_true_paths()
	for setting in settings_list:
		setting._last_created_at=_true_path+"/%s"%layer_name
		setting._full_path=_true_path+"/%s"%layer_name


func remove_sub_list(sub_list_resource):
	sub_lists.erase(sub_list_resource)



