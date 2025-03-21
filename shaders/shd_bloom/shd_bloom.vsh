attribute vec3 in_Position;    // Vertex position (x, y, z)
attribute vec4 in_Colour;      // Vertex color (r, g, b, a)
attribute vec2 in_TextureCoord; // Texture coordinates (u, v)

uniform mat4 gm_MatrixWorldViewProjection; // Built-in transformation matrix

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    // Transform the vertex position
    gl_Position = gm_MatrixWorldViewProjection * vec4(in_Position, 1.0);
    // Pass the texture coordinates and color to the fragment shader
    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour;
}
