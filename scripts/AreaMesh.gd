extends MeshInstance

var BaseLayout = load("res://scripts/RoguishGenerator.gd")

export(Vector2) var grid_size   = Vector2(32,32)
export(float)   var max_height  = 1.0 / 32.0
export(int)     var gen_seed    = 0
export(float)   var slope_width = 1.0

func _ready():

	print ("grid_size: ", self.grid_size, ", gen_seed: ", self.gen_seed)

	var base_grid_size = (grid_size / 2).floor()

	var data = BaseLayout.new(base_grid_size, self.gen_seed)

	var gx = base_grid_size.x
	var gz = base_grid_size.y    # Y in tile map is Z in 3D space
	var sw = slope_width         # This is how wide a slope compared to a tile

	var cell_scale = Vector3(1.0 / (gx + ((gx - 1) * sw)), max_height, 1.0 / (gz + ((gz - 1) * sw)) )
	var cell_delta = Vector3(cell_scale.x + (cell_scale.x * sw), 0.0, cell_scale.z + (cell_scale.z * sw))

	var surf_tool = SurfaceTool.new()
	surf_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	print ("used_rect: ", data.get_used_rect())

	for cy in range(int(grid_size.y) + 2):
		for cx in range(int(grid_size.x) + 2):
			if cx % 2 and cy % 2:
				# If both cells are odd, this is a flat bit
				draw_flat(surf_tool, cell_delta, cell_scale, data, (cx - 1) / 2, (cy - 1) / 2)
			elif cx % 2:
				# CX only is odd then is a slope in the Z direction
				draw_z_slope(surf_tool, cell_delta, cell_scale, data, (cx - 1) / 2, cy / 2)
			elif cy % 2:
				# CY only is odd then is a slope in the X direction
				draw_x_slope(surf_tool, cell_delta, cell_scale, data, cx / 2, (cy - 1) / 2)
			else:
				draw_corner(surf_tool, cell_delta, cell_scale, data, cx / 2, cy / 2)
	
	surf_tool.generate_normals()
	surf_tool.index()
	
	var mesh = Mesh.new()
	surf_tool.commit(mesh)
	self.set_mesh(mesh)

func draw_flat(surf_tool, cell_delta, cell_scale, data, data_x, data_y):
	var x = cell_delta.x * data_x
	var z = cell_delta.z * data_y

	var x2 = x + cell_scale.x
	var z2 = z + cell_scale.z

	var elevate = 1.0 if data.get_cell(data_x, data_y) else 0.0
	var y = cell_scale.y * elevate

	var tl = Vector3(x , y, z )
	var tr = Vector3(x2, y, z )
	var bl = Vector3(x , y, z2)
	var br = Vector3(x2, y, z2)

	var color = Color(0.0, 0.0, elevate)

	draw_quad(surf_tool, tl, tr, bl, br, color)

func draw_z_slope(surf_tool, cell_delta, cell_scale, data, data_x, data_y):
	var x = cell_delta.x * data_x
	var z = cell_delta.z * data_y + cell_scale.z

	var x2 = x + cell_scale.x
	var z2 = (data_y + 1) * cell_delta.z

	var elevate = 1.0 if data.get_cell(data_x, data_y) else 0.0
	var elevate2 = 1.0 if data.get_cell(data_x, data_y + 1) else 0.0
	var y = cell_scale.y * elevate
	var y2 = cell_scale.y * elevate2

	var tl = Vector3(x , y , z )
	var tr = Vector3(x2, y , z )
	var bl = Vector3(x , y2, z2)
	var br = Vector3(x2, y2, z2)

	var color = Color(0.0, 0.0, (elevate + elevate2) / 2.0)

	draw_quad(surf_tool, tl, tr, bl, br, color)

func draw_x_slope(surf_tool, cell_delta, cell_scale, data, data_x, data_y):
	var x = cell_delta.x * data_x + cell_scale.x
	var z = cell_delta.z * data_y

	var x2 = (data_x + 1) * cell_delta.x
	var z2 = z + cell_scale.z

	var elevate = 1.0 if data.get_cell(data_x, data_y) else 0.0
	var elevate2 = 1.0 if data.get_cell(data_x + 1, data_y) else 0.0
	var y = cell_scale.y * elevate
	var y2 = cell_scale.y * elevate2

	var tl = Vector3(x , y , z )
	var tr = Vector3(x2, y2, z )
	var bl = Vector3(x , y , z2)
	var br = Vector3(x2, y2, z2)

	var color = Color(0.0, 0.0, (elevate + elevate2) / 2.0)

	draw_quad(surf_tool, tl, tr, bl, br, color)

func draw_corner(surf_tool, cell_delta, cell_scale, data, data_x, data_y):
	var x = cell_delta.x * data_x + cell_scale.x
	var z = cell_delta.z * data_y + cell_scale.z

	var x2 = (data_x + 1) * cell_delta.x
	var z2 = (data_y + 1) * cell_delta.z

	var elevate_tl = 1.0 if data.get_cell(data_x, data_y) else 0.0
	var elevate_tr = 1.0 if data.get_cell(data_x + 1, data_y) else 0.0
	var elevate_bl = 1.0 if data.get_cell(data_x, data_y + 1) else 0.0
	var elevate_br = 1.0 if data.get_cell(data_x + 1, data_y + 1) else 0.0

	var y_tl = cell_scale.y * elevate_tl
	var y_tr = cell_scale.y * elevate_tr
	var y_bl = cell_scale.y * elevate_bl
	var y_br = cell_scale.y * elevate_br

	var tl = Vector3(x , y_tl, z )
	var tr = Vector3(x2, y_tr, z )
	var bl = Vector3(x , y_bl, z2)
	var br = Vector3(x2, y_br, z2)

	var color = Color(0.0, 0.0, (elevate_tl + elevate_tr + elevate_bl + elevate_br) / 4.0)

	draw_quad(surf_tool, tl, tr, bl, br, color)


func draw_quad(surf_tool, tl, tr, bl, br, color):
	surf_tool.add_color(color)
	surf_tool.add_vertex(tl)
	
	surf_tool.add_color(color)
	surf_tool.add_vertex(tr)
	
	surf_tool.add_color(color)
	surf_tool.add_vertex(bl)
	
	surf_tool.add_color(color)
	surf_tool.add_vertex(bl)

	surf_tool.add_color(color)
	surf_tool.add_vertex(tr)

	surf_tool.add_color(color)
	surf_tool.add_vertex(br)