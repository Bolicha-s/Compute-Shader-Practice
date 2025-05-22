#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16) in;

layout(set = 0, binding = 0, rgba8) uniform writeonly image2D out_image;

void main() {
    // Calculate the pixel coordinate from the global invocation ID.
    ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);
    
    // Write the red color.
    // If using normalized floats for an rgba8 image:
    imageStore(out_image, pixel_coords, vec4(1.0, 0.0, 0.0, 1.0));
    
    // Alternatively, if your image is treated as an integer image, use:
    // imageStore(out_image, pixel_coords, ivec4(255, 0, 0, 255));
}