extends RigidBody3D
@onready var function := get_tree().current_scene.get_node("Function")


var mouse_sensitivity := 0.00075
var twist_input := 0.0
var pitch_input := 0.0
#var view_dist = 1

var Fn

@onready var twist_pivot := $PivotTwist
@onready var pitch_pivot := $PivotTwist/PivotPitch
@onready var menu_pivot := $MenuPivot #/MenuRotate
@onready var menu_dist := $MenuPivot/MenuDist
@onready var camera3d := $PivotTwist/PivotPitch/Camera3D
@onready var menu2d := $MenuRotate/MenuDist/Sprite3D/SubViewport
@onready var dummy_node := $DummyNode
@onready var menu_mesh := $MenuPivot/MenuDist/MenuMesh
@onready var menu_text := $MenuPivot/MenuDist/Sprite3D/SubViewport/MenuText
@onready var menu_sprite := $MenuPivot/MenuDist/Sprite3D 

var Logo_Clicked = false
var move_ASDW = true
var d_t = 0.0

var DummyObj = "DummyObject"
var Color_Dummy = [Color.CRIMSON, Color.AQUA, Color.BLUE, Color.BLUE_VIOLET, Color.YELLOW]
var Show_Dummy  = [true,          false,      false,      false,             false]       

#var Input_Vals = [6.0,      5.0,      4.0,             4.0,         18.0]
var Bldg_W = 12.5
var Bldg_H = 6.0
var Frame_Sp = 6.0
var Nos_Frame = 5.0 #2.0 #
var Input_Vals =  [ Bldg_W,   Bldg_H,   Frame_Sp,        Nos_Frame,   Frame_Sp * Nos_Frame]
var Input_Names = ["Bldg_W", "Bldg_H", "Frame Spacing", "Nos_Frame", "Bldg_L"]
var Input_Min =   [5.0,       4.0,      6.0,             2.0,         12.0]
var Input_Max =   [30.0,      15.0,     9.0,             20.0,        180.0]

var d_y_Slider = 27
var i_y_Slider = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.linear_damp = 3.0
	show_dummy("Ini")
	slider_ini()
	menu_script()
	d_t = 0.0
	print("Player 51: todo, diagonal plates, EW cols, curb lower, slab, tier bracing, bracing roof, optimize")
	self.gravity_scale = 0 #initial no gravity
	
	Fn = function.Function.new()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input := Vector3.ZERO
	if move_ASDW:
		if Input.is_key_pressed(KEY_A): input.x = -1.0
		elif Input.is_key_pressed(KEY_D): input.x = 1.0
		elif Input.is_key_pressed(KEY_W): input.z = -1.0
		elif Input.is_key_pressed(KEY_S): input.z = 1.0
	else:
		if Input.is_key_pressed(KEY_UP): input.z = -1.0
		elif Input.is_key_pressed(KEY_DOWN): input.z = 1.0
		elif Input.is_key_pressed(KEY_LEFT): input.x = -1.0
		elif Input.is_key_pressed(KEY_RIGHT): input.x = 1.0
	
	if Input.is_key_pressed(KEY_SPACE): input.y = 1.0
	elif Input.is_key_pressed(KEY_X): input.y = -1.0
	if Input.is_key_pressed(KEY_G):
		var gravity_val = int(fmod(self.gravity_scale+1,2))
		self.gravity_scale = gravity_val
		#print("Player 78, gravity scale=",self.gravity_scale)
	
	var applied_force = twist_pivot.basis
	apply_central_force(applied_force * input * 1200.0 * delta) 	
	#print("Applied force: ", applied_force)
	
	#Rotate the player
	self.get_child(0).rotate_y(twist_input) 
	#Rotate the menu
	menu_pivot.rotate_y(twist_input) 
	#Rotate the camera
	twist_pivot.rotate_y(twist_input) 
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(30))
	twist_input = 0.0
	pitch_input = 0.0




func show_dummy(this_Type, this_Pos = Vector3(0,0,0), rayOrigin = Vector3(0,0,0), rayEnd = Vector3(0,0,0)):
	if this_Type == "Ini":
		###Dummy objects for referencing ray, 3 points, rayOrigin, rayEnd, the intersect
		for i in range(len(Color_Dummy)):
			var Dummy_Node = Node3D.new()
			Dummy_Node.name = DummyObj + str(i)
			var Dummy_Obj = CSGSphere3D.new()
			Dummy_Obj.radius = 0.1
			if i == 3:
				Dummy_Obj = CSGCylinder3D.new()
				Dummy_Obj.radius = 0.01		
			var material = StandardMaterial3D.new()
			material.albedo_color = Color_Dummy[i] # Color.CRIMSON
			Dummy_Obj.set_material(material)
			Dummy_Node.add_child(Dummy_Obj)
			Dummy_Node.visible = false
			dummy_node.add_child(Dummy_Node)
	else:
		###Dummy Object	
		var this_Pt0 = self.find_children(DummyObj+"0", "", true, false)[0]
		var this_Pt1 = self.find_children(DummyObj+"1", "", true, false)[0]
		var this_Pt2 = self.find_children(DummyObj+"2", "", true, false)[0]
		var this_Line3 = self.find_children(DummyObj+"3", "", true, false)[0]
		var this_Pt4 = self.find_children(DummyObj+"4", "", true, false)[0]
		this_Pt0.visible = Show_Dummy[0]
		this_Pt1.visible = Show_Dummy[1]
		this_Pt2.visible = Show_Dummy[2]
		this_Line3.visible = Show_Dummy[3]
		this_Pt4.visible = Show_Dummy[4]
		this_Pt0.global_position = this_Pos #this is the collision
		this_Pt1.global_position = rayOrigin #start of the ray
		this_Pt2.global_position = rayEnd #end of the ray
		this_Line3.global_position = Fn.joint("Average",[rayOrigin,rayEnd],true)
		this_Pt4.global_position = menu_mesh.global_position # Dummy to check
		var this_Rot = Fn.space_angle(rayOrigin, rayEnd)
		var Rot_A = 3*PI/2 - this_Rot[0] 
		var Rot_B = PI/2 + 2*PI - this_Rot[1]
		this_Line3.rotation = Vector3(Rot_B, Rot_A, 0) #this_Rot[0],0
		this_Line3.get_child(0).height = float(Fn.dist(rayOrigin, rayEnd))





func _unhandled_input(event: InputEvent) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	#var click_position = menu2d.get_mouse_position()
	#print("global pos: ", mouse_position, ", menu pos:", click_position)
	if event is InputEventMouseMotion:
		###Regular moving of mouse for perspective
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): 
			slider_control(event, mouse_position)


func slider_ini():
	for i in range(len(Input_Names)):
		var new_Slider = HSlider.new()
		new_Slider.set_anchors_preset(10)
		new_Slider.name = Input_Names[i]
		new_Slider.set_position(Vector2(0, i_y_Slider+i*d_y_Slider))
		new_Slider.value = Input_Vals[i]
		new_Slider.min_value = Input_Min[i]
		new_Slider.max_value = Input_Max[i]
		if "Nos" in Input_Names[i]:
			pass
		else:
			new_Slider.step = 0.1
		self.find_child("SubViewport").add_child(new_Slider)


func slider_control(event, mouse_position):
	#The code below are important, do not change
	var rayOrigin = camera3d.project_ray_origin(event.position) #Origin of the ray, from camera
	var rayLen = 1000.0 #Project out, more the accuracy, less is for dummy check ray
	var rayEnd = camera3d.project_ray_normal(mouse_position) * rayLen #Project out
	var this_World = get_world_3d().direct_space_state
	var this_Ray = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	var this_Int = this_World.intersect_ray(this_Ray) #This is the collision object
	var this_Obj = this_Int.get("collider")
	var this_Pos = this_Int.get("position") #This is the collision point
	#the code above are important, do not change
	if is_instance_of(this_Obj, TYPE_NIL): 
		pass
	else:
		var Obj_Name = this_Obj.get_parent().get_parent().to_string()
		#print("Player 172,", Obj_Name)
		if "MenuDist" in Obj_Name:
			slider_parameters(this_Pos)
			#To debug the menu movements with the Pt# and Line#
			if Show_Dummy: #for showing the points
				show_dummy("Ray", this_Pos, rayOrigin, rayEnd)
		#elif logo_mesh.name in Obj_Name:
			#Logo_Clicked = true
			#print("Player 179, clicked logo")
		elif "Wall" in Obj_Name:
			#print("Player 182, clicked Wall", Obj_Name, "---", this_Obj.get_parent().get_parent())
			#if d_t == 0.0:
				#building.create_door(this_Obj.get_parent())
				#d_t = 20.0
			#else: d_t -= 1.0
			if Show_Dummy: #for showing the points
				show_dummy("Ray", this_Pos, rayOrigin, rayEnd)
		else:
			print("Player 188, clicked SMTH:", Obj_Name, "---", this_Obj.get_parent().get_parent())
			print("Player 195, clicked SMTH:", Obj_Name, "---", this_Obj.get_parent())
			show_dummy("Ray", this_Pos, rayOrigin, rayEnd)
		
			
			


func slider_parameters(point):
	#var Pt_mc = menu_mesh.position
	var Pt_0 = self.global_position
	var Pt_m = menu_mesh.global_position
	var l_h = Fn.dist(point, Pt_m) #hypotenuse, for calc adj and opp
	var l_o = point[1] - Pt_m[1] #length opposite to int, measures which slider
	var l_a = (l_h**2 - l_o**2)**0.5 #length adjacent to int, meaaures the "ratio"
	var Pt_c = Vector3(point[0], Pt_m[1], point[2])
	var l_A = Fn.dist(Pt_c, Pt_0)
	var l_B = Fn.dist(Pt_c, Pt_m)
	var l_C = Fn.dist(Pt_0, Pt_m)
	var d_A = Fn.cos_law(l_A, l_B, l_C)*180/PI
	var Mesh_Size = menu_sprite.get_aabb().size
	var Mesh_W = float(Mesh_Size[0])
	var Mesh_H = float(Mesh_Size[1])
	var d_sign = 1.0
	if d_A < 90.0: d_sign = -1.0
	var ratio = d_sign * l_a/(Mesh_W)
	var d_y_range = 0.15
	var d_y_list = [Mesh_H/2.0-0.5, Mesh_H/2.0-0.75, Mesh_H/2.0-1.05, Mesh_H/2.0-1.28] #, Mesh_H/2.0-1.55]
	var Adjust_L = false
	var Adjust_Sp = false
	#var d_y = 0.4
	#print("check dy lc: ", d_y, ",", l_c, ", shapesize:", menu_mesh.position)# menu_sprite.get_frame_coords())
	var this_Name = "NA"
	for i in range(len(d_y_list)):
		if l_o <= d_y_list[i]+d_y_range and l_o > d_y_list[i]-d_y_range:
			this_Name = Input_Names[i]
			if i == 2 or i == 3:
				Adjust_L = true
			break
	#for i in range(len(Input_Names)):
	if this_Name in Input_Names:
		var this_Slider = self.find_children(this_Name, "", true, false)[0]
		var min = this_Slider.min_value
		var max = this_Slider.max_value
		var mid = (max+min)/2.0
		var range = float(max-min)
		var this_val = min(max(mid+ratio*range,min),max)
		this_Slider.value = this_val
		
		#Force the "Bldg L" slider = Bldg Sp x Frame Nos
		if Adjust_L or Adjust_Sp:
			var Frame_Sp = self.find_children(Input_Names[2], "", true, false)[0].value 
			var Nos_Frame = self.find_children(Input_Names[3], "", true, false)[0].value 
			var Bldg_L = self.find_children(Input_Names[4], "", true, false)[0].value 
			var Bldg_L_val = Frame_Sp * Nos_Frame
			#var Frame_Sp_val = Bldg_L / Nos_Frame
			if Adjust_L:
				self.find_children(Input_Names[4], "", true, false)[0].value = Bldg_L_val
			#elif Adjust_Sp:
				#self.find_children(Input_Names[2], "", true, false)[0].value = Frame_Sp_val
	menu_script()
		


#####CUSTOM FUNCTIONS

func menu_script():
	var text_Start = "Building inputs (metric): \n"
	var text_Menu = text_Start 
	for i in range(len(Input_Names)):
		var this_Slider = self.find_children(Input_Names[i], "", true, false)[0]
		var this_Val = float(this_Slider.value)
		text_Menu += Input_Names[i] + " = " + str(snapped(this_Val,0.01)) 
		if "Nos" not in Input_Names[i]:
			text_Menu += " m"
		text_Menu += "\n"
	menu_text.text = text_Menu

		
		
