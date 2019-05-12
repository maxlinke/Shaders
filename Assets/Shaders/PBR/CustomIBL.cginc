struct IBLSurfaceOutput {
    half3 Albedo;
    half Metallic;
    half3 Normal;
    half3 Emission;
    half Alpha;
    half Smoothness;
};

samplerCUBE _EnvironmentMap;
half _DiffuseMipLevel;
half _IndirectIntensity;
      
half4 LightingCustomIBL (IBLSurfaceOutput s, half3 viewDir, UnityGI gi) {
    s.Normal = normalize(s.Normal);

    half3 specularTint;
    half oneMinusReflectivity;
    s.Albedo = DiffuseAndSpecularFromMetallic(s.Albedo, s.Metallic, specularTint, oneMinusReflectivity);

    half4 c;
    c.rgb = UNITY_BRDF_PBS(
        s.Albedo, 
        specularTint,
        oneMinusReflectivity,
        s.Smoothness,
        s.Normal,
        viewDir,
        gi.light,
        gi.indirect
    ) + s.Emission;
    c.a = s.Alpha;
    return c;
}

void LightingCustomIBL_GI (IBLSurfaceOutput s, UnityGIInput data, inout UnityGI gi) {
    ResetUnityGI(gi);

    gi.light = data.light;
    gi.light.color *= data.atten;
    gi.light.dir = data.light.dir;

    half3 reflectedView = reflect(-data.worldViewDir, s.Normal);
    half roughness = 1.0 - (s.Smoothness * s.Smoothness);

    gi.indirect.diffuse = texCUBElod (_EnvironmentMap, half4(s.Normal, _DiffuseMipLevel)) * _IndirectIntensity;
    gi.indirect.specular = texCUBElod (_EnvironmentMap, half4(reflectedView, roughness * _DiffuseMipLevel)) * _IndirectIntensity;
}