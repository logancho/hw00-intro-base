#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


vec3 random3(vec2 p) {
    return fract(sin(vec3(dot(p, vec2(270.1, 311.8)),
                            dot(p, vec2(269.5, 183.3)),
                            dot(p, vec2(830.6, 631.2))
                        )
                    ) 
            * 43758.547224);
}

float surflet3D(vec3 p, vec3 neighbor) {
    vec3 t2 = abs(p - neighbor);
    vec3 t = vec3(1.f) - 6.f * vec3(pow(t2.x, 5.f), pow(t2.y, 5.f), pow(t2.z, 5.f))
            + 15.f * vec3(pow(t2.x, 4.f), pow(t2.y, 4.f), pow(t2.z, 4.f))
            - 10.f * vec3(pow(t2.x, 3.f), pow(t2.y, 3.f), pow(t2.z, 3.f));

    // Get the random vector for the grid point (assume we wrote a function random3
    // that returns a vec3 in the range [0, 1])

    vec3 gradient = random3(vec2(neighbor)) * 2.0 - vec3(1.0, 1.0, 1.0);

    // Get the vector from the grid point to P
    vec3 diff = p - neighbor;

    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);

    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * t.x * t.y * t.z;
    // return 1.0;
}

float perlinNoise3D(vec3 i) {
    float surfletSum = 0.f;
    for(int dx = 0; dx <= 1; ++dx) {
        for(int dy = 0; dy <= 1; ++dy) {
            for(int dz = 0; dz <= 1; ++dz) {
                surfletSum += surflet3D(i, floor(i) + vec3(dx, dy, dz));
            }
        }
    }
    return surfletSum;
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.9;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        //Calculate perlin noise:

        float perlinNoise = perlinNoise3D(vec3(fs_Pos));
        // vec4 output = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
        vec4 finalColor = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

        // if (fs_Nor.rgb == vec3(1.f, 0.f, 0.f)) {
        //     finalColor = vec4(0.f, 1.f, 0.f, 1.f);
        // }
        // out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
        // vec4 finalColor(perlinNoise > 0.5 ? vec4(1.f, 0.f, 0.f, 1.f) : vec4(0.f, 0.f, 1.f, 1.f), 1.0);
        // if (perlinNoise > 0.2) {
        //     finalColor = vec4(1.f, 0.f, 0.f, 1.f);
        // } else {
        //     finalColor = vec4(0.f, 1.f, 0.f, 1.f);
        // }
        perlinNoise *= 1.f;

        
        if (perlinNoise <= 0.2) {
            finalColor = vec4(0.f, 1.f, 0.f, 1.f);
            // finalColor = perlinNoise * normalize(vec4(1.f));
            finalColor = smoothstep(vec4(0.f), vec4(1.f), vec4(perlinNoise * 0.02f));
        }
        // out_Col = perlinNoise * normalize(vec4(1.f));
        out_Col = finalColor;
}





