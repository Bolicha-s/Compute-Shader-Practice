extends TextureRect

# Global variables for clarity.
var rd                # RenderingDevice instance.
var texture_width = 512
var texture_height = 512
var output_texture_rid  # The low-level texture RID created via RenderingServer.

func _ready():
	# Get the RenderingDevice.
	rd = RenderingServer.get_rendering_device()
	
	# =============================================================================
	# STEP 1. Create an Image with valid pixel data.
	# =============================================================================
	var img = Image.new()
	# Create an image of size (512x512) using the format RGBA8.
	img.create(texture_width, texture_height, false, Image.FORMAT_RGBA8)
	# Fill the image with opaque black. This ensures the internal buffer is allocated.
	img.fill(Color(0, 0, 0, 1))
	# Force a conversion to ensure the pixel buffer is committed.
	img.convert(Image.FORMAT_RGBA8)
	print("Image size after creation: ", img.get_width(), "x", img.get_height())
	
	# Wrap the pixel data (PackedByteArray) into an array.
	var initial_data = [ img.get_data() ]
	
	# =============================================================================
	# STEP 2. Create a GPU texture for the compute shader.
	# =============================================================================
	# Create a texture format descriptor.
	var tex_format = RDTextureFormat.new()
	tex_format.width = texture_width
	tex_format.height = texture_height
	tex_format.array_layers = 1
	tex_format.mipmaps = 1    # One mipmap level.
	tex_format.depth = 1
	tex_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tex_format.format = Image.FORMAT_RGBA8
	
	# Create a default texture view.
	var tex_view = RDTextureView.new()
	
	# Create the texture. Note the order: (format, view, initial_data).
	output_texture_rid = rd.texture_create(tex_format, tex_view, initial_data)
	print("Output Texture RID:", output_texture_rid)
	
	# =============================================================================
	# STEP 3. Load and set up the compute shader.
	# =============================================================================
	# Load the compute shader resource. Save your shader as a .rsh file.
	var shader_resource = preload("res://COMPUTE TEST.glsl")
	var shader_rid = shader_resource.get_rid()
	print("Compute Shader RID:", shader_rid)
	
	# Create the compute pipeline using the shader.
	var pipeline = rd.compute_pipeline_create(shader_rid)
	print("Compute Pipeline RID:", pipeline)
	
	# =============================================================================
	# STEP 4. Bind our GPU texture to the compute shader as an image uniform.
	# =============================================================================
	var uni = RDUniform.new()
	uni.binding = 0  # Must match "binding = 0" in the shader.
	uni.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uni.add_id(output_texture_rid)
	
	# Create (or retrieve) a uniform set for set index 0.
	var uniform_set = UniformSetCacheRD.get_cache(shader_rid, 0, [uni])
	
	# =============================================================================
	# STEP 5. Record and dispatch the compute shader.
	# =============================================================================
	var cl = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(cl, pipeline)
	rd.compute_list_bind_uniform_set(cl, uniform_set, 0)
	
	# Assuming our shader declares a local workgroup size of 16x16, calculate groups.
	var local_size = 16
	var groups_x = int(ceil(texture_width / float(local_size)))
	var groups_y = int(ceil(texture_height / float(local_size)))
	rd.compute_list_dispatch(cl, groups_x, groups_y, 1)
	
	rd.compute_list_end()
	rd.submit()
	rd.sync()
	print("Compute shader dispatched and executed.")
	
	# =============================================================================
	# STEP 6. Read back the computed texture and display it.
	# =============================================================================
	# Get the raw pixel data from the GPU. This returns a PackedByteArray.
	var computed_data = rd.texture_get_data(output_texture_rid, 0)

# Create a new Image from that raw data. You must provide the dimensions, mipmaps flag, and format.
	var computed_image = Image.create_from_data(texture_width, texture_height, false, Image.FORMAT_RGBA8, computed_data)

# Create an ImageTexture from the computed Image.
	var display_texture = ImageTexture.new()
	display_texture.create_from_image(computed_image)

# Assign it to the TextureRect.
	self.texture = display_texture
	#print("Computed image data size: ", computed_image.size())
	
