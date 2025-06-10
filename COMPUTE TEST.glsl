#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16) in;

layout(set = 0, binding = 0, rgba8) uniform writeonly image2D out_image;

//pluse one for evens function
vec4 plus_one_for_evens(vec4 color) {
    color.g = clamp(color.g +1.0, 0.0, 1.0);
    return color;
}

void main() {
    // Calculate the pixel coordinate from the global invocation ID.
    ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);

    //BELOW IS MY EDIT
    vec4 color = vec4(1.0,0.0,0.0,1.0);

    if ((pixel_coords.x % 2 == 0) && (pixel_coords.y % 2 ==0)){

       color = plus_one_for_evens(color);
    }
    
    // Write the red color.
    // If using normalized floats for an rgba8 image:
    //imageStore(out_image, pixel_coords, vec4(1.0, 0.0, 0.0, 1.0));

    imageStore(out_image, pixel_coords, color);
    
    // Alternatively, if your image is treated as an integer image, use:
	// El Blobo : Yeeaaaah, I won't use that one if i were you.
    //imageStore(out_image, pixel_coords, ivec4(255, 0, 0, 255));
}
