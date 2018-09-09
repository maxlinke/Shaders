struct CustomSurfaceOutput{
	fixed3 Albedo;
	fixed3 SpecCol;
	fixed3 Normal;
	fixed3 Emission;
	fixed Hardness;
	fixed Alpha;
	fixed Roughness;
};

inline half4 LightingCustomLambert (CustomSurfaceOutput s, half3 lightDir, half atten) {
	lightDir = normalize(lightDir);
	s.Normal = normalize(s.Normal);
	half diff = saturate(dot(lightDir, s.Normal));
	half4 c;
	c.rgb = diff * atten * s.Albedo * _LightColor0.rgb;
	c.a = s.Alpha;
	return c;
}

inline half4 LightingCustomBlinnPhong (CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
	lightDir = normalize(lightDir);
	viewDir = normalize(viewDir);
	s.Normal = normalize(s.Normal);

	half diff = saturate(dot(lightDir, s.Normal));

	half3 halfVec = normalize(lightDir + viewDir);
	half spec = pow(saturate(dot(s.Normal, halfVec)), s.Hardness * 128.0);

	half4 c;
	c.rgb = ((diff * s.Albedo) + (spec * s.SpecCol)) * atten * _LightColor0.rgb;
	c.a = s.Alpha;
	return c;
}

inline half4 LightingCustomOrenNayer (CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
	lightDir = normalize(lightDir);
	viewDir = normalize(viewDir);
	s.Normal = normalize(s.Normal);

	half nDotL = dot(s.Normal, lightDir);
	half nDotV = dot(s.Normal, viewDir);
	half lDotV = dot(lightDir, viewDir);

	half roughSQ = s.Roughness * s.Roughness;
	half3 orenNayerFraction = roughSQ / (roughSQ + half3(0.33, 0.13, 0.09));
	half3 orenNayer = half3(1,0,0) + half3(-0.5, 0.17, 0.45) * orenNayerFraction;
	half orenNayerS = lDotV - nDotL * nDotV;
	orenNayerS /= lerp(max(nDotL, nDotV), 1, step(orenNayerS, 0));

	half3 someFactor = orenNayer.x;
	someFactor += s.Albedo * orenNayer.y;
	someFactor += orenNayer.z * orenNayerS;	

	half4 c;
	c.rgb = s.Albedo * saturate(nDotL) * someFactor * atten * _LightColor0.rgb;
	c.a = s.Alpha;
	return c;
}

//almost the same, but a bit darker and i dont like that. gotta do some more experimenting
//mostly taken from https://github.com/glslify/glsl-diffuse-oren-nayar/blob/master/index.glsl

//inline half4 LightingCustomOrenNayer (CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
//	lightDir = normalize(lightDir);
//	viewDir = normalize(viewDir);
//	s.Normal = normalize(s.Normal);
//
//	half lDotV = dot(lightDir, viewDir);
//	half nDotV = dot(s.Normal, viewDir);
//	half nDotL = dot(s.Normal, lightDir);
//
//	half vS = lDotV - nDotL * nDotV;
//	half vT = lerp(1.0, max(nDotL, nDotV), step(0.0, vS));
//
//	half roughSQ = s.Roughness * s.Roughness;
////	half3 vA = 1.0 + roughSQ * (s.Albedo / (roughSQ + 0.13) + 0.5 / (roughSQ + 0.33));	//<- this line ruins everything...
//	half vA = 1.0 - 0.5 * roughSQ / (roughSQ + 0.33);										//<- my fix (à la wikipedia...)
//	half vB = 0.45 * roughSQ / (roughSQ + 0.09);
//	half3 orenNayerFactor = (vA + vB * vS / vT);
//
//	half4 c;
//	c.rgb = s.Albedo * saturate(nDotL) * orenNayerFactor * atten * _LightColor0.rgb;
//	c.a = s.Alpha;
//	return c;
//}
