##THIS ATTEMPT WASNT WORKING, I THOUGHT MAYBE IT WAS BECAUSE I WAS
##TRYING TO PULL THE IMAGE FROM RES INSTEAD OF USER. BUT ONCE I MOVED
##IT TO USED IT COULDN'T FIND THE FILE ANYMORE

##I DONT KNOW IF THAT WAS THE ISSUE THOUGH, THE SHADER MIGHT JUST NOT
##BE RUNNING


extends Node

var rd : RenderingDevice
var shader : RID
var pipeline : RID
var imageFilePath : String = "user://512_test_image.png"



func _init() -> void:
	print(OS.get_user_data_dir())

	var img = Image.new()
	var err = img.load("user://512_test_image.png")
	if err != OK:
		print("couldnt get the texture")
		return

	var texture = ImageTexture.new()
	texture.create_from_image(img)
	self.texture = texture
	RenderingServer.call_on_render_thread(initialize_compute_shader)
	_run_the_shader()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and shader.is_valid():
		RenderingServer.free_rid(shader)

	pass

#func _render_callback(effect_callback_type: int, render_data : RenderData) -> void:

func _run_the_shader() -> void:
	print("we are in render callback")
	if not rd: return
	#var scene_buffers

	#var scene_buffers : RenderSceneBufferRD = render_data.get_render_scene_buffers()
	#if not scene_buffers: return

	var size : Vector2i

	size = Vector2(512,512)

	if size.x == 0 or size.y ==0:
		print("we are in the size 0 return")
		return

	var x_groups : int = size.x / 16
	var y_groups : int = size.y / 16

	var push_constants : PackedFloat32Array = PackedFloat32Array()
	push_constants.append(size.x)
	push_constants.append(size.y)
	push_constants.append(0.0)
	push_constants.append(0.0)
	#for view in scene_buffers.get_view_count()
		#var screen_texture : RID = scene_buffers.get_color_layer(view)
		#
	var uniform : RDUniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = 0

	var texture = load(imageFilePath)

	#Ensure that the resource loaded is valid
	if texture:
		var rid = texture.get_rid()
		uniform.add_id(rid)
	else:
		print("failed to load texture from " + imageFilePath)
		#
	var image_uniform_set : RID = UniformSetCacheRD.get_cache(shader, 0, [uniform])
		#
	var compute_list : int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, image_uniform_set, 0)
	rd.compute_list_set_push_constant(compute_list, push_constants.to_byte_array(), push_constants.size() +4)
	rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
	rd.compute_list_end()

func initialize_compute_shader() -> void:

	rd = RenderingServer.get_rendering_device()
	if not rd: return

	var glsl_file :RDShaderFile = load("res://COMPUTE TEST.glsl")
	shader = rd.shader_create_from_spirv(glsl_file.get_spirv())

	pipeline = rd.compute_pipeline_create(shader)
	print("We are initializing the compute shader")



	pass
