#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16) in;

layout(set = 0, binding = 0, rgba8) uniform writeonly image2D out_image;
layout(set = 0, binding = 1, rgba8) uniform image2D canvas;                     //CANVAS
layout(set = 0, binding = 2, rgba8) uniform readonly image2D brush_texture;     //BRUSH
layout(set = 0, binding = 3, rgba8) uniform readonly image2D buffer_texture;    //BUFFER


layout(set = 0, binding = 4, std430) buffer UniformBlock{
    float testFloat;
    float testInput[10];
};



//layout(std140, set = 0, binding = 4) uniform VariousParameters {
//    float brush_angle;                                                          // Holds an angle in rads
//    vec2 mouse_position;                                                        // Position of the mouse on screen
//    vec2 canvas_position;                                                       // Canvas position on screen
//    vec2 canvas_size;                                                           // Canvas Size
//    float canvas_angle;                                                         // Rotation of the canvas in radians
//    float opacity_multiplier;                                                   // Brush opacity multiplier (0 - 1)
//    bool draw_active;                                                           // Communicates if the brush is drawing
//    vec2 brush_size;                                                            // Brush size

//};

                                                                                //plus one for evens function
vec4 plus_one_for_evens(vec4 color) {
    color.g = clamp(color.g +1.0, 0.0, 1.0);
    return color;
}

                                                                                //Local Mouse Position finder function
vec2 mouse_local_position(vec2 mouse_position, vec2 canvas_position, vec2 canvas_size){
    return vec2(0.0, 0.0);
}

                                                                                //CANVAS rotation function
mat2 canvas_angle_matrix(float canvas_angle) {
    return mat2(vec2(1.0,1.0), vec2(1.0,1.0));
}

                                                                                //BRUSH rotation function
mat2 brush_angle_matrix(float brush_angle) {
    return mat2(vec2(1.0,1.0), vec2(1.0,1.0));
}

                                                                                //BRUSH STAMPER function

void main() {
    // Calculate the pixel coordinate from the global invocation ID.
    ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);

    //BELOW IS MY EDIT
    vec4 color = vec4(1.0,0.0,0.0,1.0);

    if ((pixel_coords.x % 2 == 0) && (pixel_coords.y % 2 ==0)){

       color = plus_one_for_evens(color);
    }

    if (gl_GlobalInvocationID.x == 0 && gl_GlobalInvocationID.y == 0) {
    testFloat = testFloat * 2.0;
    }

    
    // Write the red color.
    // If using normalized floats for an rgba8 image:
    //imageStore(out_image, pixel_coords, vec4(1.0, 0.0, 0.0, 1.0));

    imageStore(out_image, pixel_coords, color);
    
    // Alternatively, if your image is treated as an integer image, use:
	// El Blobo : Yeeaaaah, I won't use that one if i were you.
    //imageStore(out_image, pixel_coords, ivec4(255, 0, 0, 255));
}
