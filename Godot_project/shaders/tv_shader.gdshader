shader_type spatial;

uniform sampler2D tv_texture; // La texture de la vidéo
uniform vec2 screen_size = vec2(1.0, 1.0); // Taille de l'écran

void fragment() {
    vec2 uv_adjusted = vec2(UV.x * (screen_size.x / screen_size.y), UV.y); // Ajustement UV
    vec4 video_color = texture(tv_texture, uv_adjusted);
    ALBEDO = video_color.rgb;
    ALPHA = video_color.a;
}

