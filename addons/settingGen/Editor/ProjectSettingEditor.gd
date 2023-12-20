@tool
extends Control


var active_loaded_file:RootProjectSettingList:
	set(val):
		active_loaded_file=val
		update_loaded_file(active_loaded_file)
var selected_sublist:ProjectSettingList=null


const var_types:int=37

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event):
	if event is InputEventMouseButton and not event.pressed and event.button_index == 1:
		var drag_data=get_viewport().gui_get_drag_data()
		if drag_data==null or drag_data.type!="files" or len(drag_data.files)!=1:return
		#if it is not the right type, stop you
		var loaded_file:=load(drag_data.files[0]) as RootProjectSettingList
		if loaded_file == null:return
		var name_of_file=drag_data.files[0].split("/")
		
		$Layout/ActiveProjectSettingList/Label.text=name_of_file[len(name_of_file)-1]
		active_loaded_file=loaded_file


func update_loaded_file(file):
	var tree=$Layout/SettingList/VBoxContainer/Tree
	tree.clear()
	active_loaded_file.generate_true_paths()
	generate_on_tree(tree,file,null)
	last_selected_tree_item=null
	selected_sublist=null


func generate_on_tree(tree:Tree,file,attaching_to=null):
	var my_item=tree.create_item(attaching_to)
	my_item.set_text(0,file.layer_name)
	#my_item.set_editable(0,true)
	for list in file.sub_lists:
		generate_on_tree(tree,list,my_item)
	



func _on_tree_item_mouse_selected(position, mouse_button_index):
	var tree:Tree = $Layout/SettingList/VBoxContainer/Tree
	var tree_item:TreeItem=tree.get_selected()
	var path_travelled:Array[TreeItem]=[]
	
	
	while tree_item!=null:
		path_travelled.push_front(tree_item)
		tree_item=tree_item.get_parent()
	
	var full_path=""
	for item in path_travelled:full_path+=item.get_text(0)+"/"
	
	var settings_found=active_loaded_file.get_settings_at_path(full_path)
	var new_selected_sublist=active_loaded_file.traverse_to(full_path)
	
	
	selected_sublist=new_selected_sublist
	
	clear_setting_list()
	load_setting_list(settings_found)



func clear_setting_list():
	var settingContainer=$Layout/SettingList/VBoxContainer2/SettingListContainer
	
	for child in settingContainer.get_children():child.queue_free()
	


func load_setting_list(setting_list):
	var settingContainer=$Layout/SettingList/VBoxContainer2/SettingListContainer
	if setting_list==null:return
	for setting in setting_list:
		var setting_input=setting.load_menu_input(true)
		settingContainer.add_child(setting_input)
		pass

func _setting_grabbed_focus(current_setting):
	pass




func _on_add_layer_pressed():
	if active_loaded_file==null:return
	var layer_name_input=$Layout/SettingList/VBoxContainer/layer_name
	if layer_name_input.text==""||selected_sublist==null:return
	var new_sub_list=ProjectSettingList.new()
	new_sub_list.layer_name=layer_name_input.text
	selected_sublist.sub_lists.push_back(new_sub_list)
	
	layer_name_input.text=""
	update_loaded_file(active_loaded_file)
	active_loaded_file.notify_property_list_changed()


func _on_delete_setting_pressed():
	if active_loaded_file==null:return
	pass # Replace with function body.


func _on_delete_layer_pressed():
	if active_loaded_file==null:return
	var path_to=active_loaded_file.traverse_to(
		selected_sublist._true_path
		)
	if path_to:
		path_to.remove_sub_list(selected_sublist)
	update_loaded_file(active_loaded_file)
	active_loaded_file.notify_property_list_changed()


func _on_add_setting_to_layer_pressed():
	if active_loaded_file==null||selected_sublist==null:return
	var setting_name_input=$Layout/SettingList/VBoxContainer2/HBoxContainer/VBoxContainer/Label2
	var setting_type_input:OptionButton=$Layout/SettingList/VBoxContainer2/HBoxContainer/VBoxContainer/HBoxContainer/OptionButton
	var setting_advanced_check=$Layout/SettingList/VBoxContainer2/HBoxContainer/VBoxContainer/Button
	
	#prevent multiple sharing the same name
	if len(selected_sublist.settings_list.filter(func(v):return v.setting_name==setting_name_input.text))>0:return
	
	
	var new_project_setting=ProjectSetting.new(
		setting_name_input.text,
		setting_type_input.selected,
		setting_advanced_check.button_pressed
	)
	selected_sublist.settings_list.push_back(
		new_project_setting
	)
	
	clear_setting_list()
	load_setting_list(selected_sublist.settings_list)
	
	
	




func get_traversal_path_using_tree_item(tree_item:TreeItem):
	var path_travelled:Array[TreeItem]=[]
	while tree_item!=null:
		path_travelled.push_front(tree_item)
		tree_item=tree_item.get_parent()
	
	var full_path=""
	for item in path_travelled:full_path+=item.get_text(0)+"/"
	return full_path




func _on_tree_item_edited():
	var tree:Tree=$Layout/SettingList/VBoxContainer/Tree
	var edited:TreeItem=tree.get_edited()
	#if it is a sub layer
	if edited.get_parent():
		var sub_list_index=edited.get_parent().get_children().find(edited)
		var edit_path=get_traversal_path_using_tree_item(edited)
		var split_path=edit_path.split("/")
		var editing_resource=active_loaded_file.traverse_to(edit_path.trim_suffix(split_path[len(split_path)-2]+"/"))
		
		editing_resource.sub_lists[sub_list_index].layer_name=edited.get_text(0)
	else:
		#top layer being changed
		active_loaded_file.layer_name=edited.get_text(0)
	
	active_loaded_file.generate_true_paths()

var last_selected_tree_item:TreeItem=null
func _on_tree_item_selected():
	var tree:Tree=$Layout/SettingList/VBoxContainer/Tree
	var selected_item=tree.get_selected()
	#ignore any null values
	if last_selected_tree_item:
		last_selected_tree_item.set_editable(0,false)
	selected_item.set_editable(0,true)
	last_selected_tree_item=selected_item
