precision mediump float;

uniform sampler2D u_Texture;   // Custom texture uniform
uniform float intensity;       // Bloom intensity control

varying vec2 v_vTexcoord;      // Passed texture coordinates
varying vec4 v_vColour;        // Passed vertex color

const float blurSize = 1.0 / 512.0;  // Adjust this value based on your texture resolution

void main() {
    vec4 sum = vec4(0.0);

    // Horizontal blur
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x - 4.0 * blurSize, v_vTexcoord.y)) * 0.05;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x - 3.0 * blurSize, v_vTexcoord.y)) * 0.09;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x - 2.0 * blurSize, v_vTexcoord.y)) * 0.12;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x - blurSize, v_vTexcoord.y)) * 0.15;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y)) * 0.16;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x + blurSize, v_vTexcoord.y)) * 0.15;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x + 2.0 * blurSize, v_vTexcoord.y)) * 0.12;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x + 3.0 * blurSize, v_vTexcoord.y)) * 0.09;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x + 4.0 * blurSize, v_vTexcoord.y)) * 0.05;

    // Vertical blur
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y - 4.0 * blurSize)) * 0.05;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y - 3.0 * blurSize)) * 0.09;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y - 2.0 * blurSize)) * 0.12;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y - blurSize)) * 0.15;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y)) * 0.16;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y + blurSize)) * 0.15;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y + 2.0 * blurSize)) * 0.12;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y + 3.0 * blurSize)) * 0.09;
    sum += texture2D(u_Texture, vec2(v_vTexcoord.x, v_vTexcoord.y + 4.0 * blurSize)) * 0.05;

    // Combine the blur with the original texture
    gl_FragColor = sum * intensity + texture2D(u_Texture, v_vTexcoord) * (1.0 - intensity);
}
