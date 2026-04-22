extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


class Function:
	var d_Tol = 0.01 / 1000
	var DOF = 6
	var mm_to_m = 1.0 / 1000
	var m_to_mm = 1000.0
	var dec = 6
	
	func xyz(cd, Action="Godot"):
		var X = cd[1] #Y(1)=Xg[0]
		var Y = cd[2] #Z(2)=Yg[1]
		var Z = cd[0] #X(0)=Zg[2]
		if Action != "Godot": #Zg->X, Xg->Y, Yg->Z
			X = cd[2] #Zg[2]=X(0)
			Z = cd[1] #Yg[1]=Z(2)
			Y = cd[0] #Xg[0]=Y(1)
		var cd_r = Vector3(X,Y,Z) 
		return cd_r
	
	
	func round_to(val, dec):
		var OUT 
		OUT = snappedf(val,1.0/(10**dec))
		return OUT
		
	func trans_rot(X, Y, Z, A, B, C): #Coordinates XYZ, Angles ABC respect to ZYX-axes in rad (Angle_A, Angle_B, m_Rot)
		var R_11 = cos(A)*cos(B)
		var R_12 = cos(A)*sin(B)*sin(C) - sin(A)*cos(C)
		var R_13 = cos(A)*sin(B)*cos(C) + sin(A)*sin(C)
		var R_21 = sin(A)*cos(B)
		var R_22 = sin(A)*sin(B)*sin(C) + cos(A)*cos(C)
		var R_23 = sin(A)*sin(B)*cos(C) - cos(A)*sin(C)
		var R_31 = -sin(B)
		var R_32 = cos(B)*sin(C)
		var R_33 = cos(B)*cos(C)
		var X_rev = X*R_11 + Y*R_12 + Z*R_13
		var Y_rev = X*R_21 + Y*R_22 + Z*R_23
		var Z_rev = X*R_31 + Y*R_32 + Z*R_33
		return [X_rev, Y_rev, Z_rev]


	func linear_int(xi,x0,x1,y0,y1):
		var yi = y0+(xi-x0)*(y1-y0)/(x1-x0)
		return yi


	func dist(cd_i,cd_j):
		var Length = ((cd_i[0]*1.0-cd_j[0]*1.0)**2+(cd_i[1]*1.0-cd_j[1]*1.0)**2+(cd_i[2]*1.0-cd_j[2]*1.0)**2)**0.5
		return Length
	
	func cos_law(A, B, C): #C is opposite side of the angle
		var angle_A = 0
		if B*C != 0:
			angle_A = acos((C**2+B**2-A**2)/(2*B*C))
		return angle_A

	func space_angle(jt_i,jt_j,Action="Default"):
		var d_X = (jt_j[0]-jt_i[0])*1.0
		var d_Y = (jt_j[1]-jt_i[1])*1.0
		var d_Z = (jt_j[2]-jt_i[2])*1.0
		var d_L = (d_X**2 + d_Y**2)**0.5
		var Angle_A
		var Angle_B
		if (d_X == 0 and d_Y == 0) or d_L == 0: Angle_A = PI/2 #0.0 <- naturally 0, but for D in Y axis, set to 90 deg
		elif d_X == 0 and d_Y > 0: Angle_A = PI/2
		elif d_X == 0 and d_Y < 0: Angle_A = 3*PI/2
		elif d_X > 0 and d_Y >= 0: Angle_A = atan(d_Y/d_X)
		elif d_X > 0 and d_Y < 0: Angle_A = 2*PI + atan(d_Y/d_X)
		else: Angle_A = PI + atan(d_Y/d_X)
		var Angle_Af = fmod(Angle_A,2*PI) #(Angle_A * 180/math.pi % 360) * math.pi/180
		if d_L == 0 and d_Z >= 0: Angle_B = PI/2
		elif d_L == 0 and d_Z < 0: Angle_B = 3*PI/2
		else: Angle_B = atan(d_Z/d_L)
		var Angle_Bf = 2*PI - fmod(Angle_B,2*PI)#fmod(Angle_B*180/PI,360) * PI/180
		if Action == "Godot":
			Angle_Bf += PI/2
			Angle_Af += PI/2
			
		return [Angle_Af, Angle_Bf]


	func get_color(colorString,div=255.0):
		var colorInt = [255, 255, 255]
		var colorList = ["WHITE","BLACK","GREY","BROWN",
		"RED","GREEN","BLUE","YELLOW","ORANGE", 
		"CYAN","VIOLET","PURPLE","PINK"]
		var colorInts = [[255, 255, 255], [0, 0, 0], [120, 120, 120], [150, 75, 0],
		[255, 0, 0], [0, 255, 0], [0, 0, 255],[255, 255, 0], [255, 200, 0], 
		[0, 255, 255],[140, 70, 255], [120, 0, 120], [255, 0, 150]]
		var shadeD = -50
		var shadeDD = 2*shadeD
		var shadeL = 50
		var shadeLL = 2*shadeL
		var shadeList = ["DARK+", "DARK", "LIGHT+", "LIGHT"]
		var shadeInts = [[shadeDD, shadeDD, shadeDD], [shadeD, shadeD, shadeD], 
		[shadeLL, shadeLL, shadeLL], [shadeL, shadeL, shadeL]]
		for i in range(len(colorList)):
			if colorList[i].to_upper() in colorString.to_upper():
				colorInt = colorInts[i]; break
		for j in range(len(shadeList)):
			if shadeList[j].to_upper() in colorString.to_upper():
				for p in range(len(colorInt)):
					colorInt[p] += shadeInts[j][p]
				break
		var R_code = min(max(int(colorInt[0]), 0), 255) / div
		var G_code = min(max(int(colorInt[1]), 0), 255) / div
		var B_code = min(max(int(colorInt[2]), 0), 255) / div
		var colorCode = [R_code, G_code, B_code]
		return colorCode


	func sort_zip(IN_List,check_Unique=false):
		var Ref_List = IN_List[0]
		var Ref_Sort = []
		for i in range(len(Ref_List)):
			var this_val = Ref_List[i]
			var is_Unique = true
			if check_Unique:
				for j in range(len(Ref_Sort)):
					var this_ref = Ref_Sort[j]
					if abs(this_ref - this_val) < d_Tol:
						is_Unique = false
						break
			if is_Unique:
				Ref_Sort += [this_val]
		Ref_Sort.sort()
		
		var ind_sort = []
		for i in range(len(Ref_Sort)):
			var val_s = Ref_Sort[i]
			var ind_s = Ref_List.find(val_s)
			ind_sort += [ind_s]
			
		var OUT_List = []
		for u in range(len(IN_List)):
			var this_List = []
			if u == 0:
				this_List = Ref_Sort
			else:
				for v in range(len(ind_sort)):
					var ind_f = ind_sort[v]
					var val_f = IN_List[u][ind_f]
					this_List += [val_f]
			OUT_List += [this_List]
		return OUT_List
		

	func point_int(jt_0,jt_i,jt_j,No_Overlap=false,Get_Ratio=false):
		var is_int = false
		var Len_ij = dist(jt_i, jt_j)
		var Len_in = dist(jt_i, jt_0)
		var Len_jn = dist(jt_j, jt_0)
		if abs(Len_ij - Len_in - Len_jn) < d_Tol: is_int= true
		if No_Overlap:
			if is_int:
				if Len_in < d_Tol or Len_jn < d_Tol: is_int = false
		var OUT = is_int
		if Get_Ratio:
			var ratio = 1.0 * Len_in / (1.0 * Len_ij)
			OUT = [is_int, ratio]
		return OUT


	func parametric_line(jt_i,jt_j): #, decimal = 6.0):
		var d_Jt = joint("Difference",[jt_i,jt_j])
		var x_0 = jt_i[0]
		var y_0 = jt_i[1]
		var z_0 = jt_i[2]
		var x_t = d_Jt[0] 
		var y_t = d_Jt[1] 
		var z_t = d_Jt[2]
		var OUT = [[x_0*1.0, x_t*1.0],[y_0*1.0, y_t*1.0],[z_0*1.0, z_t*1.0]]# x=x0+a*t; y=y0+b*t; z=z0+c*t
		return OUT

	
	func area_triangle(Pt_a, Pt_b, Pt_c):
		#Area = |V_ab x V_ac | / 2 = |V_ab || V_ac ||sin0| / 2
		#Magnitude of vector = sqrt(x^2 + y^2 + z^2)
		var V_ab = joint("Difference", [Pt_b, Pt_a])
		var V_ac = joint("Difference", [Pt_c, Pt_a])
		var V_cross = vector("Cross",V_ab, V_ac) #self.cross_product(V_ab, V_ac)
		var Area = 0.5 * vector("Magnitude", V_cross)
		return Area
	
	
	func area_polygon(Pts, pt_0=[]):
		var pt_m = pt_0
		if len(pt_0) == 0: pt_m = joint("Average", Pts)
		var Area = 0.0
		for i in range(len(Pts)):
			var pt_i = Pts[i-1]
			var pt_j = Pts[i]
			Area += abs(area_triangle(pt_m, pt_i, pt_j))
		return Area
	
	
	func point_bounded(this_pt, surf_pts, Shrink_Val=0.0, Show_Ratio=false):
		var is_bounded = false
		var this_surf_pts = [] #[[] for i in range(len(surf_pts))]
		this_surf_pts.resize(len(surf_pts))
		if Shrink_Val > 0:
			for i in range(len(surf_pts)):
				var pt_0 = surf_pts[i]
				var pt_2 = surf_pts[i-2]
				var new_pt = joint("Project", [pt_0, pt_2, Shrink_Val])
				this_surf_pts[i] = new_pt
		else: this_surf_pts = surf_pts
		var Area_surf = area_polygon(this_surf_pts)
		var Area_pt  = area_polygon(this_surf_pts, this_pt)
		var d_Area = abs(Area_surf - Area_pt)
		if d_Area < d_Tol:
			is_bounded = true
		var OUT = is_bounded
		if Show_Ratio: OUT = [is_bounded, d_Area]
		return OUT
	
	
	func plane_int(jt_i,jt_j,plane_jts,is_bound=true):
		var is_int = false
		var cd_int = []
		#var is_eqn = true
		var jt_0 = plane_jts[0]
		var jt_1 = plane_jts[1]
		#var jt_2 = plane_jts[2]
		var jt_3 = plane_jts[3]
		var plane_eqn = vector("Cross",jt_0,jt_1,jt_3,false,true) #cross_product(jt_0,jt_1,jt_3,Plane_Eqn=True)
		var a0 = plane_eqn[0]
		var b0 = plane_eqn[1]
		var c0 = plane_eqn[2]
		var d0 = plane_eqn[3]
		var xyz_e = parametric_line(jt_i, jt_j) #xe,ye,ze = line_eqn
		var xe = xyz_e[0]
		var ye = xyz_e[1]
		var ze = xyz_e[2]
		#a0 = xe[0]+xe[1]*t #b0 = ye[0]+ye[1]*t #c0 = ze[0]+ze[1]*t
		#a0*xe[1]*t + b0*ye[1]*t + c0*ze[1]*t + (a0*xe[0]+b0*ye[0]+c0*ze[0]+d0) = 0
		if (a0*xe[1]+b0*ye[1]+c0*ze[1]) != 0:
			var t = -(a0*xe[0]+b0*ye[0]+c0*ze[0]+d0)/(a0*xe[1]+b0*ye[1]+c0*ze[1])
			var x1 = xe[0] + xe[1]*t
			var y1 = ye[0] + ye[1]*t
			var z1 = ze[0] + ze[1]*t
			cd_int = [x1, y1, z1]
			is_int = point_int(cd_int, jt_i, jt_j)
			if is_bound:
				is_int = point_bounded(cd_int,plane_jts)
		return [is_int, cd_int]
	

	func line_int(jt_i,jt_j,jt_0,jt_1):#,d_w=10.0):
		var d_np = vector("Cross",jt_0,jt_i,jt_j)
		var d_nn = [-d_np[0],-d_np[1],-d_np[2]]
		var jt_a = joint("Add",[jt_i,d_np])
		var jt_b = joint("Add",[jt_i,d_nn])
		var jt_c = joint("Add",[jt_j,d_nn])
		var jt_d = joint("Add",[jt_j,d_np])
		var jts = [jt_a,jt_b,jt_c,jt_d]
		var OUT = plane_int(jt_0,jt_1,jts,false)
		if OUT[0]:
			var is_int = point_int(OUT[1],jt_i,jt_j)
			OUT[0] = is_int
		return OUT
		
		
	func joint(Action,jt_input,As_Vector=false):
		var jt_n = [0.0,0.0,0.0]
		if Action == "Add":
			for i in range(len(jt_input)):
				var d_jt = jt_input[i]
				jt_n[0] += d_jt[0]
				jt_n[1] += d_jt[1]
				jt_n[2] += d_jt[2]
		elif Action == "Average":
			var jt_a = joint("Add",jt_input)
			var div = len(jt_input)*1.0
			jt_n = [jt_a[0]/div,jt_a[1]/div,jt_a[2]/div]
		elif Action == "Difference":
			var jt_a = jt_input[0]
			var jt_b = jt_input[1]
			jt_n = [jt_a[0]-jt_b[0],jt_a[1]-jt_b[1],jt_a[2]-jt_b[2]]
		elif Action == "Project" or Action == "Forecast": #Project is dist; Forecast is ratio
			var jt_i = jt_input[0]
			var jt_j = jt_input[1]
			var d_jt = jt_input[2]
			var Len = dist(jt_i,jt_j)*1.0
			var Ratio = d_jt
			if Action == "Project": Ratio = d_jt*1.0/Len
			var d_n = joint("Difference",[jt_j,jt_i])
			jt_n = [jt_i[0]+Ratio*d_n[0], jt_i[1]+Ratio*d_n[1], jt_i[2]+Ratio*d_n[2]]

		var OUT = jt_n #Vector3(jt_n[0],jt_n[1],jt_n[2])
		if As_Vector: OUT = Vector3(jt_n[0],jt_n[1],jt_n[2])
		return OUT


	func vector(Action,vt0,vt1=[],vt2=[],is_Normalise=false,Plane_Eqn=false):
		var OUT = []
		if Action in ["Dihedral","Dihedral Angle"]:
			var m0 = vector("Magnitude",vt0)
			var m1 = vector("Magnitude",vt1)
			var d01 = vector("Dot",vt0,vt1)
			OUT = acos(abs(d01)/(m0*m1))
		elif Action in ["Magnitude", "Mag"]:
			var vt
			if vt0 is Array:
				vt = vt0
			else:
				vt = [vt0,vt1,vt2]
			OUT = (vt[0]**2 + vt[1]**2 + vt[2]**2)**0.5
		elif Action in ["Dot", "Dot Product"]:
			var v_a = vt0
			var v_b = vt1
			if len(vt2) ==3: 
				v_a = joint("Difference", [vt1, vt0])
				v_b = joint("Difference", [vt2, vt0])
			OUT = v_a[0]*v_b[0]+v_a[1]*v_b[1]+v_a[2]*v_b[2]
		elif Action in ["Cross", "Cross Product"]:
			var vtn = [0.0,0.0,0.0]
			if len(vt2) ==3: 
				var v_a = joint("Difference", [vt1, vt0])
				var v_b = joint("Difference", [vt2, vt0])
				vtn = vector("Cross",v_a, v_b)
			else:
				vtn[0] = vt0[1] * vt1[2] - vt0[2] * vt1[1]
				vtn[1] = -1.0*(vt0[0] * vt1[2] - vt0[2] * vt1[0])
				vtn[2] = vt0[0] * vt1[1] - vt0[1] * vt1[0]
			OUT = vtn
			var v_x = vtn[0]
			var v_y = vtn[1] 
			var v_z = vtn[2]
			if is_Normalise:
				var v_max = 1.0*max(abs(v_x),abs(v_y),abs(v_z))
				var vtm = [v_x/v_max, v_y/v_max, v_z/v_max]
				OUT = vtm
			if Plane_Eqn:
				var d0 = -1.0*(v_x*vt0[0]+v_y*vt0[1]+v_z*vt0[2])
				OUT = [v_x,v_y,v_z,d0] #OUT = [a0,b0,c0,d0]
		elif Action == "Angle":
			var u = vt0
			var v = vt1
			if len(vt2) == 3:
				u = joint("Difference", [vt1, vt0])
				v = joint("Difference", [vt2, vt0])
			var uv_dot = u[0]*v[0] + u[1]*v[1] + u[2]*v[2]
			var uv_mag = (u[0]**2+u[1]**2+u[2]**2)**0.5 * (v[0]**2+v[1]**2+v[2]**2)**0.5
			var angle = "NA"
			if uv_mag != 0 and abs(uv_dot/uv_mag) <= 1.0: angle = acos(uv_dot / uv_mag)
			OUT = angle
		elif Action == "Absolute":
			var vt_list = []
			for i in range(len(vt0)):
				vt_list += [abs(vt0[i])]
			var max_val = vt_list.max()
			var ind_m = vt0.find(max_val)
			OUT = vt0[ind_m]
		elif Action == "Multiply":
			var vtm = vt0
			if vt1 is float:
				vtm = [vt0[0]*vt1,vt0[1]*vt1,vt0[2]*vt1]
			OUT = vtm
		return OUT



	func print_list(List,prefix="",dec=3):
		for i in range(len(List)):
			var this_Line = List[i]
			if this_Line is float:
				this_Line = round_to(this_Line,dec) #snappedf(this_Line,1.0/(10**dec))
				print("Fn 722,", prefix, " id=", i, ":", this_Line)
			else:
				for j in range(len(this_Line)):
					if this_Line[j] is float:
						this_Line[j] = round_to(this_Line[j],dec) #snappedf(this_Line[j],1.0/(10**dec))
				print("Fn 727,", prefix, " id=", i, ":", this_Line )
