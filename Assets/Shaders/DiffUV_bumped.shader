Shader "Custom/DiffUV (bumped)" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[Normal] _NormTex ("Normal Map", 2D) = "bump" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CustomLambert
		#include "CustomLighting.cginc"

		sampler2D _MainTex;
		sampler2D _NormTex;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
			float2 uv_NormTex;
		};

		void surf (Input IN, inout CustomSurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_NormTex, IN.uv_NormTex));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
