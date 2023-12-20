@tool
extends Node
var picker_val=null
var type_of_picker:int=36



func _get_property_list():
	return [
		{
			name="picker_val",
			type=type_of_picker
		}
	]
