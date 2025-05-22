##THIS WAS ME JUST LETTING AI DO IT.
##IT DOESN'T WORK HAHA


extends TextureRect

func _ready() -> void:
	# Create a local rendering device.
	var rd = RenderingServer.create_local_rendering_device()

	# Load the modified compute shader (saved as "res://image_red_compute.glsl").
	var shader_file = load("res://COPILOT GLSL.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader = rd.shader_create_from_spirv(shader_spirv)

	# Create a new 512x512 image in RGBA8 format.
	var image = Image.new()
	image.create(512, 512, false, Image.FORMAT_RGBA8)
	
	# Fill the image with white (for example) so that the change to red is obvious.
	#image.lock()
	for y in range(512):
		for x in range(512):
			image.set_pixel(x, y, Color(1, 1, 1, 1))
	#image.unlock()
	
	# Get the raw byte data from the image.
	var image_data = image.get_data()  # This is a PackedByteArray.
	
	# Calculate the expected size in bytes: 512 * 512 pixels * 4 bytes per pixel.
	var size_bytes = 512 * 512 * 4
	
	# Create a texture buffer from the image data.
	# (The second parameter is the data format; we're using Image.FORMAT_RGBA8 here.)
	var texture_rid = rd.texture_buffer_create(size_bytes, RenderingDevice.DataFormat.DATA_FORMAT_R8G8B8A8_SINT, image_data)
	
	# Create a uniform for binding the texture.
	var uniform = RDUniform.new()
	# Use the texture uniform type for binding.
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_TEXTURE
	uniform.binding = 0
	uniform.add_id(texture_rid)
	
	# Create the uniform set for set index 0.
	var uniform_set = rd.uniform_set_create([uniform], shader, 0)
	
	# Create the compute pipeline.
	var pipeline = rd.compute_pipeline_create(shader)
	var compute_list = rd.compute_list_begin()
	
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	
	# Dispatch the compute shader.
	# With a workgroup size of 16 in both X and Y, dispatching 32x32x1 will cover a 512x512 area.
	rd.compute_list_dispatch(compute_list, 32, 32, 1)
	rd.compute_list_end()
	
	# Submit the compute commands and wait for completion.
	rd.submit()
	rd.sync()
	
	# Retrieve the modified texture data.
	var output_bytes = rd.texture_buffer_get_data(texture_rid)
	
	# Create an Image from the output bytes.
	var output_image = Image.new()
	output_image.create_from_data(512, 512, false, Image.FORMAT_RGBA8, output_bytes)
	
	# Create an ImageTexture from the updated image and display it.
	var out_tex = ImageTexture.create_from_image(output_image)
	self.texture = out_tex
	
	print("Image processing complete: every pixel should now be red!")
