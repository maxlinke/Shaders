Shader "Custom/PBR/IBL" {

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
	
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
		LOD 200

		CGPROGRAM

		#include "UnityPBSLighting.cginc"
        #include "CustomIBL.cginc"

		#pragma surface surf CustomIBL
		#pragma target 3.0

        fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _MetallicGlossMap;
		sampler2D _BumpMap;
		sampler2D _EmissionMap;
		// samplerCUBE _EnvironmentMap;
		// half _DiffuseMipLevel;
        // half _IndirectIntensity;

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
