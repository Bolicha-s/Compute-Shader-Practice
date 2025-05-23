extends TextureRect

# Global variables for clarity.
var rd                # RenderingDevice instance.
var output_texture_rid  # The low-level texture RID created via RenderingServer.

@onready var shader : RID
@onready var uniform_set : RID
@onready var pipeline : RID

func _ready():
	assert(texture != null and texture is Texture2DRD) # Just be sure the scene is correctly set ^^

	# Get the RenderingDevice.
	rd = RenderingServer.get_rendering_device()

	# Create a texture format descriptor.
	var tex_format = RDTextureFormat.new()
	tex_format.width = size.x
	tex_format.height = size.y
	tex_format.array_layers = 1
	tex_format.mipmaps = 1    # One mipmap level.
	tex_format.depth = 1
	tex_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	# This data format is valid. Not all are. In the shader, it is declared as rgba8.
	tex_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	# Without those flags, you can use the texture as a uniform in your shader.
	tex_format.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT

	# Create a default texture view.
	var tex_view = RDTextureView.new()

	# Create the texture. Note the order: (format, view, initial_data).
	output_texture_rid = rd.texture_create(tex_format, tex_view, [ _create_image_filled_with_color(Vector2i(size), Color.SALMON) ])
	assert(output_texture_rid.is_valid())
	# Link the texture directly to the texture of the TextureRect.
	(texture as Texture2DRD).texture_rd_rid = output_texture_rid

	# Load the compute shader resource. Save your shader as a .rsh file.
	shader = _init_shader("res://COMPUTE TEST.glsl")
	assert(shader.is_valid())
	# Create the sampler uniform.
	var uniforms : Array[RDUniform] = []
	var sampler : RDUniform = RDUniform.new()
	sampler.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	sampler.binding = 0 # As declared in the shader (binding = 0)
	sampler.add_id(output_texture_rid)
	uniforms.append(sampler)
	# And the uniform set.
	uniform_set = rd.uniform_set_create(uniforms, shader, 0) # Let set shader_set to 0 for now.
	# And finally the rendering pipeline.
	pipeline = rd.compute_pipeline_create(shader)

	# We are all set ! For now, the image contain a neat Salmon color. Hit space, and the shader will be run and change the color to red.

func _input(event : InputEvent) -> void:
	if event is InputEventKey:
		var kev : InputEventKey = event as InputEventKey
		if kev.pressed and (not kev.echo) and kev.keycode == KEY_SPACE:
			# Run the shader on space bar hit. Will execute the shader and change the texels to red.
			RenderingServer.call_on_render_thread(_run_shader)

func _run_shader() -> void:
	var render_list : int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(render_list, pipeline)
	rd.compute_list_bind_uniform_set(render_list, uniform_set, 0)
	rd.compute_list_dispatch(render_list, ceili(size.x / 16.0), ceili(size.y / 16.0), 1) # In the shader, the local site size for x and y is 16.
	rd.compute_list_end()

func _create_image_filled_with_color(sz : Vector2i, color : Color) -> PackedByteArray:
	var count : int = sz.x * sz.y
	var res : PackedByteArray = PackedByteArray()
	res.resize(count * 4)
	for i : int in range(count):
		var o : int = i * 4
		res[o] = color.r8; res[o + 1] = color.g8; res[o + 2] = color.b8; res[o + 3] = color.a8
	return res

func _init_shader(path : String) -> RID:
	var shader_file : RDShaderFile = load(path)
	var shader_spirv : RDShaderSPIRV = shader_file.get_spirv()
	if shader_spirv.compile_error_compute != "":
		push_error(shader_spirv.compile_error_compute)
		assert(false)
	return rd.shader_create_from_spirv(shader_spirv)
