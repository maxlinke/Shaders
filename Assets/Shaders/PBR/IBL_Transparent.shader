Shader "Custom/PBR/IBL_Transparent" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset] _MetallicGlossMap ("Metallic (RGB) + Smoothness (A)", 2D) = "black" {}
        [NoScaleOffset] [Normal] _BumpMap ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _EmissionMap ("Emission", 2D) = "black" {}
        [NoScaleOffset] _EnvironmentMap ("Environment", CUBE) = "" {}
        _DiffuseMipLevel ("Diffuse Mip Level", Range(0.0, 20.0)) = 10.0
        _IndirectIntensity ("Indirect Intensity", Range(0.0, 2.0)) = 1.0
	}
	
	SubShader {
	
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 200

		CGPROGRAM

		#include "UnityPBSLighting.cginc"

		#pragma surface surf CustomIBL alpha:fade addshadow
		#pragma target 3.0

        struct IBLSurfaceOutput {
            half3 Albedo;
            half Metallic;
            half3 Normal;
            half3 Emission;
            half Alpha;
            half Smoothness;
        };

        fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _MetallicGlossMap;
		sampler2D _BumpMap;
		sampler2D _EmissionMap;
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

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout IBLSurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			fixed4 m = tex2D (_MetallicGlossMap, IN.uv_MainTex);
			o.Metallic = m.r;
			o.Smoothness = m.a;
			o.Normal = UnpackNormal ( tex2D (_BumpMap, IN.uv_MainTex));
			o.Emission = tex2D (_EmissionMap, IN.uv_MainTex);
		}
		
		ENDCG
		
	}
	
	FallBack "Diffuse"
}
