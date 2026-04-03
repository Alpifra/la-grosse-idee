shader_type canvas_item;
// ── Palette 32 couleurs JRPG 16-bit + dithering en damier ─────────────────────
//
// Usage post-process (plein écran) :
//   Ajouter un ColorRect (anchor 0→1) avec ce ShaderMaterial dans un CanvasLayer.
//   Le nœud doit avoir "Show Behind Parent" désactivé et layer élevé (ex: 99).
//
// Usage par objet :
//   Appliquer directement comme material sur un Sprite2D / SubViewportContainer.
//
// Technique de dithering :
//   Pour chaque pixel, on trouve les 2 couleurs palette les plus proches.
//   La matrice Bayer 2×2 décide laquelle afficher selon la position en damier.
//   Résultat : illusion de couleurs intermédiaires, fidèle aux SNES/PCE.

// Échantillon de l'image source (screen ou texture de l'objet)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// ── 32 couleurs JRPG — palette DQ / FF SNES ──────────────────────────────────
const int  PALETTE_SIZE = 32;
const vec3 PAL[32] = vec3[32](
	// Peaux & tons chauds
	vec3(0.96, 0.88, 0.70),   //  0 peau clair
	vec3(0.90, 0.74, 0.52),   //  1 peau moyen
	vec3(0.76, 0.56, 0.36),   //  2 peau foncé
	vec3(0.56, 0.30, 0.12),   //  3 brun cheveux
	vec3(0.92, 0.68, 0.28),   //  4 or / blé
	vec3(0.82, 0.42, 0.14),   //  5 orange roux
	vec3(0.68, 0.18, 0.10),   //  6 rouge sang
	vec3(0.44, 0.10, 0.08),   //  7 rouge sombre
	// Nature : herbe, forêt
	vec3(0.60, 0.88, 0.26),   //  8 vert vif
	vec3(0.24, 0.60, 0.10),   //  9 vert herbe DQ2
	vec3(0.12, 0.38, 0.06),   // 10 vert foncé forêt
	vec3(0.06, 0.20, 0.04),   // 11 vert très sombre
	vec3(0.52, 0.72, 0.18),   // 12 vert jaune (feuilles lumière)
	vec3(0.70, 0.56, 0.22),   // 13 kaki / terre sèche
	vec3(0.50, 0.34, 0.12),   // 14 brun terre
	vec3(0.32, 0.20, 0.08),   // 15 brun sombre sol
	// Ciel, eau, magie
	vec3(0.40, 0.72, 0.96),   // 16 bleu ciel clair
	vec3(0.14, 0.46, 0.82),   // 17 bleu ciel moyen
	vec3(0.06, 0.24, 0.60),   // 18 bleu nuit
	vec3(0.04, 0.10, 0.30),   // 19 bleu très sombre
	vec3(0.28, 0.82, 0.82),   // 20 cyan eau
	vec3(0.10, 0.56, 0.64),   // 21 sarcelle
	vec3(0.60, 0.36, 0.86),   // 22 violet magie
	vec3(0.34, 0.14, 0.60),   // 23 violet sombre
	// Neutres : UI, pierre, métal
	vec3(1.00, 1.00, 1.00),   // 24 blanc pur
	vec3(0.86, 0.86, 0.86),   // 25 gris clair
	vec3(0.58, 0.58, 0.60),   // 26 gris moyen
	vec3(0.30, 0.30, 0.34),   // 27 gris sombre
	vec3(0.10, 0.08, 0.14),   // 28 quasi-noir
	vec3(0.00, 0.00, 0.00),   // 29 noir pur
	vec3(0.98, 0.90, 0.40),   // 30 jaune UI / HP
	vec3(0.96, 0.96, 0.84)    // 31 ivoire texte NES
);

// ── Distance palette (distance² RGB, pas de sqrt) ─────────────────────────────
float pal_dist2(vec3 a, vec3 b) {
	vec3 d = a - b;
	return dot(d, d);
}

// Retourne l'index de la couleur palette la plus proche
int nearest(vec3 c) {
	float best = 1e9;
	int   idx  = 0;
	for (int i = 0; i < PALETTE_SIZE; i++) {
		float d = pal_dist2(c, PAL[i]);
		if (d < best) { best = d; idx = i; }
	}
	return idx;
}

// Retourne l'index du 2e voisin (pour interpolation dithering)
int second_nearest(vec3 c, int skip) {
	float best = 1e9;
	int   idx  = 0;
	for (int i = 0; i < PALETTE_SIZE; i++) {
		if (i == skip) continue;
		float d = pal_dist2(c, PAL[i]);
		if (d < best) { best = d; idx = i; }
	}
	return idx;
}

// ── Matrice de dithering Bayer 2×2 ───────────────────────────────────────────
// Seuils : 4 niveaux — produit un demi-ton très proche des circuits SNES
float bayer2(ivec2 p) {
	// Matrice Bayer ordre 2 normalisée 0…1
	//  0/4  2/4
	//  3/4  1/4
	int b = (p.x & 1) | ((p.y & 1) << 1);
	const float M[4] = float[4](0.0, 0.75, 0.5, 0.25);
	return M[b];
}

// ── Fragment ──────────────────────────────────────────────────────────────────
void fragment() {
	// Lecture de l'image source (mode screen post-process)
	vec4 src = texture(screen_texture, SCREEN_UV);

	// Pixel entier pour la matrice de dithering (coordonnée écran réelle)
	ivec2 px = ivec2(FRAGCOORD.xy);

	// Deux couleurs palette voisines
	int a = nearest(src.rgb);
	int b = second_nearest(src.rgb, a);

	// Ratio : 0 = tout A, 1 = tout B
	float da     = sqrt(pal_dist2(src.rgb, PAL[a]));
	float db     = sqrt(pal_dist2(src.rgb, PAL[b]));
	float weight = db / (da + db + 1e-5);

	// Seuillage damier Bayer
	vec3 chosen  = (weight > bayer2(px)) ? PAL[b] : PAL[a];

	COLOR = vec4(chosen, src.a);
}
