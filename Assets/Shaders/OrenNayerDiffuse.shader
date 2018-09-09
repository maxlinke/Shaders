Shader "Custom/OrenNayerDiffuse" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Roughness ("Roughness", Range(0, 1)) = 1.0
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CustomOrenNayer
		#include "CustomLighting.cginc"

		fixed4 _Color;
		fixed _Roughness;
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout CustomSurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Roughness = _Roughness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
