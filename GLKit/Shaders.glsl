#ifdef GL_VERTEX_SHADER
attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec4 a_color;
#ifdef TEXTURE0_CUBE
attribute vec3 a_texcoord0;
#else
attribute vec2 a_texcoord0;
#endif
#ifdef TEXTURE1_CUBE
attribute vec3 a_texcoord1;
#else
attribute vec2 a_texcoord1;
#endif

uniform mat4 u_modelviewprojection;
uniform mat4 u_modelview;
uniform mat3 u_normal;

uniform lowp vec4 u_color_constant;
uniform lowp vec4 u_color_ambient;

uniform vec4 u_light0_position;
uniform lowp vec4 u_light0_ambient;
uniform lowp vec4 u_light0_diffuse;
uniform lowp vec4 u_light0_specular;
uniform vec4 u_light0_spotdirection_exponent;
uniform vec4 u_light0_attenuation_cutoff;

uniform vec4 u_light1_position;
uniform lowp vec4 u_light1_ambient;
uniform lowp vec4 u_light1_diffuse;
uniform lowp vec4 u_light1_specular;
uniform vec4 u_light1_spotdirection_exponent;
uniform vec4 u_light1_attenuation_cutoff;

uniform vec4 u_light2_position;
uniform lowp vec4 u_light2_ambient;
uniform lowp vec4 u_light2_diffuse;
uniform lowp vec4 u_light2_specular;
uniform vec4 u_light2_spotdirection_exponent;
uniform vec4 u_light2_attenuation_cutoff;

uniform lowp vec4 u_material_ambient;
uniform lowp vec4 u_material_diffuse;
uniform lowp vec4 u_material_specular;
uniform lowp vec4 u_material_emissive;
uniform float u_material_shininess;

uniform mediump vec3 u_density_start_end;

#ifdef TEXTURE0_CUBE
varying mediump vec3 v_texcoord0;
#else
varying mediump vec2 v_texcoord0;
#endif
#ifdef TEXTURE1_CUBE
varying mediump vec3 v_texcoord1;
#else
varying mediump vec2 v_texcoord1;
#endif
varying mediump float v_fog;
varying lowp vec4 v_color;

void main() {
#ifdef TEXCOORD0
    v_texcoord0 = a_texcoord0;
#endif
#ifdef TEXCOORD1
    v_texcoord1 = a_texcoord1;
#endif

#if !defined(MATERIAL) && !defined(LIGHT0) && !defined(LIGHT1) && !defined(LIGHT2)
#ifdef CONSTANT_COLOR
    v_color = u_color_constant;
#else
    v_color = a_color;
#endif
#else
#ifdef COLOR_MATERIAL
#ifdef CONSTANT_COLOR
    lowp vec4 material_ambient = u_color_constant;
    lowp vec4 material_diffuse = u_color_constant;
#else
    lowp vec4 material_ambient = a_color;
    lowp vec4 material_diffuse = a_color;
#endif
#else
    lowp vec4 material_ambient = u_material_ambient;
    lowp vec4 material_diffuse = u_material_diffuse;
#endif
    v_color = u_material_emissive + u_color_ambient * material_ambient;
#if defined(LIGHT0) || defined(LIGHT1) || defined(LIGHT2)
    mediump vec3 direction;
    mediump vec3 distance;
    mediump float spotlight;
    mediump vec4 vertex_position = u_modelview * a_position;
    mediump vec3 vertex_normal = normalize(u_normal * a_normal);
#endif
#ifdef LIGHT0
    direction = u_light0_position.w * vertex_position.xyz - u_light0_position.xyz;
    distance.x = 1.0;
    distance.z = dot(direction, direction); 
    distance.y = sqrt(distance.z);
    direction = normalize(direction);
    spotlight = dot(direction, u_light0_spotdirection_exponent.xyz);
    v_color += mix(1.0, mix(ceil(max(0.5 * (spotlight - u_light0_attenuation_cutoff.w), 0.0)) * pow(spotlight, u_light0_spotdirection_exponent.w), 1.0, max(u_light1_attenuation_cutoff.w - 1.0, 0.0)) / dot(distance, u_light0_attenuation_cutoff.xyz), u_light1_position.w) * (u_light0_ambient * material_ambient + max(0.0, dot(vertex_normal, -direction)) * u_light0_diffuse * material_diffuse + pow(max(0.0, dot(vertex_normal, normalize(-direction + vec3(0.0, 0.0, 1.0)))), u_material_shininess) * u_light0_specular * u_material_specular);
#endif
#ifdef LIGHT1
    direction = u_light1_position.w * vertex_position.xyz - u_light1_position.xyz;
    distance.x = 1.0;
    distance.z = dot(direction, direction); 
    distance.y = sqrt(distance.z);
    direction = normalize(direction);
    spotlight = dot(direction, u_light1_spotdirection_exponent.xyz);
    v_color += mix(1.0, mix(ceil(max(0.5 * (spotlight - u_light1_attenuation_cutoff.w), 0.0)) * pow(spotlight, u_light1_spotdirection_exponent.w), 1.0, max(u_light1_attenuation_cutoff.w - 1.0, 0.0)) / dot(distance, u_light1_attenuation_cutoff.xyz), u_light1_position.w) * (u_light1_ambient * material_ambient + max(0.0, dot(vertex_normal, -direction)) * u_light1_diffuse * material_diffuse + pow(max(0.0, dot(vertex_normal, normalize(-direction + vec3(0.0, 0.0, 1.0)))), u_material_shininess) * u_light1_specular * u_material_specular);
#endif
#ifdef LIGHT2
    direction = u_light2_position.w * vertex_position.xyz - u_light2_position.xyz;
    distance.x = 1.0;
    distance.z = dot(direction, direction); 
    distance.y = sqrt(distance.z);
    direction = normalize(direction);
    spotlight = dot(direction, u_light2_spotdirection_exponent.xyz);
    v_color += mix(1.0, mix(ceil(max(0.5 * (spotlight - u_light2_attenuation_cutoff.w), 0.0)) * pow(spotlight, u_light2_spotdirection_exponent.w), 1.0, max(u_light2_attenuation_cutoff.w - 1.0, 0.0)) / dot(distance, u_light2_attenuation_cutoff.xyz), u_light2_position.w) * (u_light2_ambient * material_ambient + max(0.0, dot(vertex_normal, -direction)) * u_light2_diffuse * material_diffuse + pow(max(0.0, dot(vertex_normal, normalize(-direction + vec3(0.0, 0.0, 1.0)))), u_material_shininess) * u_light2_specular * u_material_specular);
#endif
#endif
#ifdef FOG
#if !defined(LIGHT0) && !defined(LIGHT1) && !defined(LIGHT2)
    mediump vec4 vertex_position = u_modelview * a_position;
#endif
#ifdef FOG_MODE_LINEAR
    v_fog = clamp((u_density_start_end.z + vertex_position.z) / (u_density_start_end.z - u_density_start_end.y), 0.0, 1.0);
#else
#ifdef FOG_MODE_EXP
    v_fog = clamp(exp(vertex_position.z * u_density_start_end.x), 0.0, 1.0);
#else
    v_fog = clamp(exp(-(vertex_position.z * vertex_position.z * u_density_start_end.x * u_density_start_end.x)), 0.0, 1.0);
#endif
#endif
#endif
    gl_Position = u_modelviewprojection * a_position;
}
#endif //GL_VERTEX_SHADER

#ifdef GL_FRAGMENT_SHADER
uniform sampler2D u_sampler0;
uniform sampler2D u_sampler1;

uniform mediump vec4 u_fog_color;

#ifdef TEXTURE0_CUBE
varying mediump vec3 v_texcoord0;
#else
varying mediump vec2 v_texcoord0;
#endif
#ifdef TEXTURE1_CUBE
varying mediump vec3 v_texcoord1;
#else
varying mediump vec2 v_texcoord1;
#endif
varying mediump float v_fog;
varying lowp vec4 v_color;

void main() {
#ifdef TEXTURE0_CUBE
#define TEXTURE0_METHOD textureCube
#else
#define TEXTURE0_METHOD texture2D
#endif
#ifdef TEXTURE1_CUBE
#define TEXTURE1_METHOD textureCube
#else
#define TEXTURE1_METHOD texture2D
#endif
#if defined(TEXCOORD0) && defined(TEXCOORD1)
#ifdef TEXTURE_ORDER
#ifdef TEXTURE_REPLACE
    gl_FragColor = v_color * TEXTURE0_METHOD(u_sampler0, v_texcoord0);
#else
#ifdef TEXTURE_DECAL
    lowp vec4 texel0 = TEXTURE0_METHOD(u_sampler0, v_texcoord0);
    gl_FragColor = v_color * mix(TEXTURE1_METHOD(u_sampler1, v_texcoord1), texel0, texel0.a);
#else
    gl_FragColor = v_color * TEXTURE0_METHOD(u_sampler0, v_texcoord0) * TEXTURE1_METHOD(u_sampler1, v_texcoord1);
#endif
#endif
#else
#ifdef TEXTURE_REPLACE
    gl_FragColor = v_color * TEXTURE1_METHOD(u_sampler1, v_texcoord1);
#else
#ifdef TEXTURE_DECAL
    lowp vec4 texel1 = TEXTURE1_METHOD(u_sampler1, v_texcoord1);
    gl_FragColor = v_color * mix(TEXTURE0_METHOD(u_sampler0, v_texcoord0), texel1, texel1.a);
#else
    gl_FragColor = v_color * TEXTURE0_METHOD(u_sampler0, v_texcoord0) * TEXTURE1_METHOD(u_sampler1, v_texcoord1);
#endif
#endif
#endif
#else
#ifdef TEXCOORD0
    gl_FragColor = v_color * TEXTURE0_METHOD(u_sampler0, v_texcoord0);
#else
#ifdef TEXCOORD1
    gl_FragColor = v_color * TEXTURE1_METHOD(u_sampler1, v_texcoord1);
#else
    gl_FragColor = v_color;
#endif
#endif
#endif
#ifdef FOG
    gl_FragColor = vec4(mix(u_fog_color.rgb, gl_FragColor.rgb, v_fog), gl_FragColor.a);
#endif
}
#endif //GL_FRAGMENT_SHADER