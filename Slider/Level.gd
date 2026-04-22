extends Node

var is_Camera = true
var activate_Menu = KEY_TAB
@onready var origin_node := $Origin

@onready var player := get_tree().current_scene.get_node("Player")
@onready var function := get_tree().current_scene.get_node("Function")
@onready var website := get_tree().current_scene.get_node("Website")
@onready var draw := get_tree().current_scene.get_node("Draw")

var Fn
var Dr

#Mesh variables
#Delay variables
var d_t = 10.0
var i_t = 0.0

#Time current, dummy for text
var t_c = 0.0
var file_path = "res://zBOM.txt"
@onready var menu_text := $Player/MenuPivot/MenuDist/Sprite3D/SubViewport/MenuText


#@onready var MenuInput = self.find_child("Player").find_child("MenuPlayer").get_children()
@onready var menu_input = self.find_child("Player").find_child("SubViewport") #.get_children()
@onready var menu_dist = self.find_children("MenuDist", "", true, false)[0]
#@onready var menu_player := $Level/Player/MenuRotate/MenuDist/Sprite3D/SubViewport/MenuPlayer

var slider_ID1 = "input1_slider"
var slider_ID2 = "input2_slider"

var Text_0_Name = "Text_0"
var Text_1_Name = "Text_1"
var Text_2_Name = "Text_2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var this_Check = self.find_children("MenuMesh", "", true, false)[0]
	menu_dist.visible = false
	Fn = function.Function.new()
	Dr = draw.Draw.new()
	Dr.add_module("Function", Fn)
	
	var axis = Dr.axis()
	var New_Node = Node3D.new()
	New_Node.name = "Axis"
	New_Node.add_child(axis)
	self.add_child(New_Node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t_c += 1
	if i_t == 0:
		#var this_label = self.find_child("MenuPlayer") 
		if Input.is_key_pressed(KEY_ESCAPE): #quit game
				get_tree().quit()

		if Input.is_key_pressed(KEY_C): #for lock/unlock viewport
			if is_Camera:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				is_Camera = false
				menu_dist.visible = true
			else: 
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				is_Camera = true


		elif Input.is_key_pressed(KEY_B):
			clear_node(Text_0_Name)
			clear_node(Text_1_Name)
			clear_node(Text_2_Name)
			var this_data = website.website()
			print("")
			print("Lv 61, website data:")
			print("Lv 62:", this_data)
			var jt_0 = [0,0,5]
			var this_Text = Dr.text(jt_0,this_data)
			this_Text.name = Text_0_Name
			self.add_child(this_Text)
			

		elif Input.is_key_pressed(KEY_N): #dummy box
			clear_node(Text_0_Name)
			clear_node(Text_1_Name)
			clear_node(Text_2_Name)
			var val_1 = website.slider(slider_ID1)
			var val_2 = website.slider(slider_ID2)
			var jt_1 = [0,2,2]
			var jt_2 = [0,2,1]
			var this_Text_1 = Dr.text(jt_1,str(val_1),0.0,"Red",50)
			this_Text_1.name = Text_1_Name
			var this_Text_2 = Dr.text(jt_2,str(val_2),0.0,"Blue",50)
			this_Text_2.name = Text_2_Name
			self.add_child(this_Text_1)
			self.add_child(this_Text_2)


		if Input.is_anything_pressed():
			#if player.Logo_Clicked:
				#send_email()
				#player.Logo_Clicked = false
			i_t += d_t
		
	i_t -= 1.0 #one frame
	i_t = max(0.0, i_t)
		

func clear_node(Node_Name):
	var Child_List = self.get_children()
	for i in range(len(Child_List)):
		var this_node = str(Child_List)
		if Node_Name in this_node:
			self.get_node(Node_Name).free() 
			
			
func print_list(List,prefix=""):
	for i in range(len(List)):
		var this_Line = List[i]
		print("Lv 167,", prefix, " id=", i, ":", this_Line )
