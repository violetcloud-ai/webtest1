extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


class Draw:
	var Fn

	
	func add_module(Action="",IN=[]):
		if Action == "Function":
			Fn = IN
	
	
	func add_color(obj,color=Color.WHITE,alpha=1.0,is_Mesh=false): #,transparency=0): #is_Mesh=false,
		var material = StandardMaterial3D.new()
		if color is String:
			if "Transparent" in color:
				alpha = 0.5
				if "(" in color and ")" in color:
					var ind_0 = color.find("(")
					var ind_1 = color.find(")")
					alpha = 1.0-float(color.substr(ind_0+1,ind_1))
			color = Fn.get_color(color)
		material.set_transparency(1)
		material.albedo_color = Color(color[0],color[1],color[2],alpha)
		if is_Mesh:
			#material.set_transparency(alpha)
			obj.set_surface_override_material(0, material)
		else:
			obj.set_material(material)

	
	func combine_obj(jt_0,jt_1=[],obj=[],mRot=0.0):
		var this_Node = Node3D.new()
		this_Node.global_position = Fn.xyz(jt_0)
		for i in range(len(obj)):
			this_Node.add_child(obj[i])
		this_Node.rotate(Vector3(0,1,0), mRot) #mRot, Roll
		if len(jt_1) == 3:
			var d_AB = Fn.space_angle(jt_0,jt_1,"Godot")
			this_Node.rotate(Vector3(0,0,1), d_AB[1]) #dB, Pitch
			this_Node.rotate(Vector3(0,1,0), d_AB[0]) #d_AB[0]) #dA, Yaw
		return this_Node
	
	
	func axis(jt_0=[0.0,0.0,0.0],len=5.0,dia=0.05):
		var jt_x = Fn.joint("Add",[jt_0,[len,0,0]])
		var jt_y = Fn.joint("Add",[jt_0,[0,len,0]]) 
		var jt_z = Fn.joint("Add",[jt_0,[0,0,len]])  
		var cyl_x = cylinder(jt_0,jt_x,dia,"Red") #print("Dr 50 Axis X, red")
		var cyl_y = cylinder(jt_0,jt_y,dia,"Green") #Color.GREEN) #print("Dr 52 Axis Y, green")
		var cyl_z = cylinder(jt_0,jt_z,dia,"Blue") #Color.BLUE) #print("Dr 54 Axis Z, blue")
		var this_axis = combine_obj(jt_0,[],[cyl_x,cyl_y,cyl_z])
		return this_axis
	
	
	func add_obj(jt_0,jt_1,this_shape,Rot=0.0,is_Center=false):
		var jt_0g = Fn.xyz(jt_0)
		var jt_1g = jt_0g
		if len(jt_1) == 3:
			jt_1g = Fn.xyz(jt_1)
		var this_Node = Node3D.new()
		this_Node.add_child(this_shape)
		var jt_c = jt_0g
		if is_Center: jt_c = Fn.joint("Average",[jt_0g,jt_1g],true)
		this_Node.global_position = jt_c
		if len(jt_1) == 3:
			var d_AB = Fn.space_angle(jt_0,jt_1,"Godot")
			#this_Node.rotate(Vector3(1,0,0), Rot) #<- ORIGINAL rot code not sure if impacts anything
			this_Node.rotate(Vector3(1,0,0), 0) #<- originally the val is Rot
			this_Node.rotate(Vector3(0,0,1), d_AB[1]) #dB, Pitch
			this_Node.rotate(Vector3(0,1,0), d_AB[0]+Rot) #<- originally only d_AB[0]
		else:
			if Rot is float:
				#this_Node.rotate(Vector3(0,1,0), Rot) #mRot, Roll
				this_Node.rotation = Vector3(0,Rot,0) #mRot, Roll
			elif Rot is Array:
				#this_Node.rotate(Vector3(0,1,0), Rot[0]) #rZ
				this_Node.rotation = Vector3(Rot[0],Rot[1],Rot[2])
				#this_Node.rotate(Vector3(0,1,0), Rot[1]) #rX
				#this_Node.rotate(Vector3(0,0,1), Rot[2]) #rY
		return this_Node
	
	
	
	func text(jt_0,Text,rot=0.0,color="Black",size=20,depth=0.02,transp=1.0):
		var this_mesh = MeshInstance3D.new()
		var text_mesh = TextMesh.new()
		text_mesh.text = Text
		text_mesh.depth = depth  
		text_mesh.font_size = size
		this_mesh.mesh = text_mesh
		add_color(this_mesh,color,transp,true)
		var this_Node = add_obj(jt_0,"",this_mesh,rot)
		return this_Node
	
	
	func sphere(jt_0,dia=0.025,color=Color.BISQUE):
		var this_sph = CSGSphere3D.new()
		this_sph.radius = dia/2.0
		add_color(this_sph,color)
		var this_Node = add_obj(jt_0,[],this_sph) #,0.0,true)
		return this_Node
	
	
	func cylinder(jt_0,jt_1,dia=0.025,color=Color.PALE_VIOLET_RED): 
		var this_cyl = CSGCylinder3D.new()
		this_cyl.height = Fn.dist(jt_0,jt_1)
		this_cyl.radius = dia/2.0
		add_color(this_cyl,color)
		var this_Node = add_obj(jt_0,jt_1,this_cyl,0.0,true)
		return this_Node
		
