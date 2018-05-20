extends MeshInstance

var BaseLayout = load("res://scripts/RoguishGenerator.gd")

export(Vector2) var grid_size  = Vector2(32,32)
export(float)   var max_height = 0.2
export(int)     var gen_seed   = 0

func _ready():

	print ("grid_size: ", self.grid_size, ", gen_seed: ", self.gen_seed)

	var data = BaseLayout.new(self.grid_size, self.gen_seed)
	var cell_scale = Vector3(1 / grid_size.x, 1 / grid_size.y, max_height)

	var surf_tool = SurfaceTool.new()
	surf_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for cy in range(int(grid_size.y) - 1):
		for cx in range(int(grid_size.x) - 1):

			var x = cx
			var y = cy
			var x2 = (cx + 1)
			var y2 = (cy + 1)

			var tl = Vector3(cell_scale.x *  cx     , cell_scale.z * data.get_cell(x , y ), cell_scale.y *  cy     )
			var tr = Vector3(cell_scale.x * (cx + 1), cell_scale.z * data.get_cell(x2, y ), cell_scale.y *  cy     )
			var bl = Vector3(cell_scale.x *  cx     , cell_scale.z * data.get_cell(x , y2), cell_scale.y * (cy + 1))
			var br = Vector3(cell_scale.x * (cx + 1), cell_scale.z * data.get_cell(x2, y2), cell_scale.y * (cy + 1))

			var tlUv = Vector2(0,0)
			var trUv = Vector2(1,0)
			var blUv = Vector2(0,1)
			var brUv = Vector2(1,1)

			surf_tool.add_uv(tlUv)
			surf_tool.add_vertex(tl)
			
			surf_tool.add_uv(trUv)
			surf_tool.add_vertex(tr)
			
			surf_tool.add_uv(blUv)
			surf_tool.add_vertex(bl)
			
			surf_tool.add_uv(blUv)
			surf_tool.add_vertex(bl)

			surf_tool.add_uv(trUv)
			surf_tool.add_vertex(tr)
	
			surf_tool.add_uv(brUv)
			surf_tool.add_vertex(br)
	
	surf_tool.generate_normals()
	surf_tool.index()
	
	var mesh = Mesh.new()
	surf_tool.commit(mesh)
	self.set_mesh(mesh)
