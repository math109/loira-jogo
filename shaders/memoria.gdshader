shader_type canvas_item;
// MEMÓRIA — o filtro das lembranças de 1998 (CG 8).
// Pega a tela inteira e muda as cores com uma MATRIZ DE COR 3x3:
// cada cor nova é uma mistura do vermelho, verde e azul antigos.
// "forca" vai de 0 (presente, cores normais) a 1 (memória): o memoria.gd
// anima esse número com um tween, e é isso que faz a transição suave (interpolação).

uniform sampler2D tela : hint_screen_texture, filter_nearest;
uniform float forca : hint_range(0.0, 1.0) = 0.0;

// Matriz sépia, a "cor de foto antiga". No GLSL a mat3 é escrita por COLUNAS:
// coluna 1 = quanto o R antigo soma em (R, G, B) novos, coluna 2 = o G, coluna 3 = o B.
//   R' = 0.393 R + 0.769 G + 0.189 B
//   G' = 0.349 R + 0.686 G + 0.168 B
//   B' = 0.272 R + 0.534 G + 0.131 B
const mat3 SEPIA = mat3(
	vec3(0.393, 0.349, 0.272),
	vec3(0.769, 0.686, 0.534),
	vec3(0.189, 0.168, 0.131));

void fragment() {
	vec3 cor = texture(tela, SCREEN_UV).rgb;

	// "Bordas de lembrança": quanto mais longe do centro, mais borrado e mais escuro.
	vec2 centro = (SCREEN_UV - 0.5) * vec2(1.0, 0.8);
	float borda = smoothstep(0.28, 0.72, length(centro));
	vec2 px = SCREEN_PIXEL_SIZE * 2.0;
	vec3 borrado = (texture(tela, SCREEN_UV + vec2(px.x, 0.0)).rgb
		+ texture(tela, SCREEN_UV - vec2(px.x, 0.0)).rgb
		+ texture(tela, SCREEN_UV + vec2(0.0, px.y)).rgb
		+ texture(tela, SCREEN_UV - vec2(0.0, px.y)).rgb) / 4.0;
	cor = mix(cor, borrado, borda * forca);

	// A matriz de cor: multiplicar a matriz pelo vetor (R, G, B).
	vec3 quente = clamp(SEPIA * cor, 0.0, 1.0);
	cor = mix(cor, quente, forca * 0.85);

	// Bordas puxando para o marrom, como papel velho.
	cor = mix(cor, cor * vec3(0.55, 0.40, 0.28), borda * forca * 0.9);

	COLOR = vec4(cor, 1.0);
}
