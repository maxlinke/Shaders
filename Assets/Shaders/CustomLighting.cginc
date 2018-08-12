struct CustomSurfaceOutput{
	fixed3 Albedo;
	fixed3 SpecCol;
	fixed3 Normal;
	fixed3 Emission;
	fixed Hardness;
	fixed Alpha;
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

//inline half4 LightingCustomBlinnPhong_Deferred (CustomSurfaceOutput s, half3 viewDir, UnityGI gi, out half4 outDiffuseOcclusion, out half4 outSpecSmoothness, out half4 outNormal) {
//
//	outDiffuseOcclusion = half4(1,1,1,1);
//	outSpecSmoothness = half4(0,0,0,0);
//	outNormal = s.Normal;
//
//	return s.Emission;
//}
