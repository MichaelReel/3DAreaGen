extends MeshInstance

var BaseLayout = load("res://scripts/RoguishGenerator.gd")

export(Vector2) var grid_size  = Vector2(16,16)
export(float)   var max_height = 1.0 / 32.0
export(int)     var gen_seed   = 0

func _ready():

	print ("grid_size: ", self.grid_size, ", gen_seed: ", self.gen_seed)

	var data = BaseLayout.new(self.grid_size, self.gen_seed)
	var cell_scale = Vector3(1 / grid_size.x, 1 / grid_size.y, max_height)

	var surf_tool = SurfaceTool.new()
	surf_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	print ("used_rect: ", data.get_used_rect())

	for cy in range(int(grid_size.y) - 1):
		for cx in range(int(grid_size.x) - 1):

			var x = cx
			var y = cy
			var x2 = (cx + 1)
			var y2 = (cy + 1)

			var this_cell = 1.0 if data.get_cell(x , y) else 0.0

			var tl = Vector3(cell_scale.x *  cx     , cell_scale.z * this_cell, cell_scale.y *  cy     )
			var tr = Vector3(cell_scale.x * (cx + 1), cell_scale.z * this_cell, cell_scale.y *  cy     )
			var bl = Vector3(cell_scale.x *  cx     , cell_scale.z * this_cell, cell_scale.y * (cy + 1))
			var br = Vector3(cell_scale.x * (cx + 1), cell_scale.z * this_cell, cell_scale.y * (cy + 1))

			var tlUv = Vector2(0,0)
			var trUv = Vector2(1,0)
			var blUv = Vector2(0,1)
			var brUv = Vector2(1,1)

			var color = Color(0.0, 0.0, this_cell)

			surf_tool.add_color(color)
			# surf_tool.add_uv(tlUv)
			surf_tool.add_vertex(tl)
			
			surf_tool.add_color(color)
			# surf_tool.add_uv(trUv)
			surf_tool.add_vertex(tr)
			
			surf_tool.add_color(color)
			# surf_tool.add_uv(blUv)
			surf_tool.add_vertex(bl)
			
			surf_tool.add_color(color)
			# surf_tool.add_uv(blUv)
			surf_tool.add_vertex(bl)

			surf_tool.add_color(color)
			# surf_tool.add_uv(trUv)
			surf_tool.add_vertex(tr)
	
			surf_tool.add_color(color)
			# surf_tool.add_uv(brUv)
			surf_tool.add_vertex(br)
	
	surf_tool.generate_normals()
	surf_tool.index()
	
	var mesh = Mesh.new()
	surf_tool.commit(mesh)
	self.set_mesh(mesh)
