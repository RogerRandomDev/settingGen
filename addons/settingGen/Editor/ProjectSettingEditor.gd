@tool
extends Control


var active_loaded_file:RootProjectSettingList:
	set(val):
		active_loaded_file=val
		update_loaded_file(active_loaded_file)

const var_types:int=37
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var setting_type:OptionButton=$Layout/SettingList/VBoxContainer2/HBoxContainer/VBoxContainer/HBoxContainer/OptionButton
	setting_type.flat=false
	setting_type.item_count=var_types
	for i in var_types:
		setting_type.add_item(
			type_string(i)
		)
	


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
	generate_on_tree(tree,file,null)
	


func generate_on_tree(tree:Tree,file,attaching_to=null):
	var my_item=tree.create_item(attaching_to)
	my_item.set_text(0,file.layer_name)
	for list in file.sub_lists:
		generate_on_tree(tree,list,my_item)
	
