#[compute]
#version 450

// We choose a local workgroup size that evenly divides the image dimensions.
// (16×16 groups will require us to dispatch 32 groups in X and Y, since 512/16 = 32.)
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

// Bind a writable 2D image. The layout qualifier “rgba8” tells the shader
// that the image is in 8-bit RGBA format. Make sure the binding and set match what we bind in GDScript.
layout(set = 0, binding = 0, rgba8) uniform writeonly image2D img;

void main() {
    // Use the global invocation IDs to compute the pixel coordinates.
    ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);
    
    // Set each pixel to red.
    imageStore(img, pixel_coords, vec4(1.0, 0.0, 0.0, 1.0));
}