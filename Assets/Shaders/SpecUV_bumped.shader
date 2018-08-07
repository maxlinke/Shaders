﻿Shader "Custom/SpecUV (bumped)" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_SpecTex ("Specular Texture", 2D) = "white" {}
		_Hardness ("Specular Hardness", Range(0,1)) = 0.5
		_NormTex ("Normal Map", 2D) = "bump" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CustomBlinnPhong
		#include "CustomLighting.cginc"

		sampler2D _MainTex;
		sampler2D _SpecTex;
		sampler2D _NormTex;
		fixed4 _Color;
//		fixed4 _SpecColor;		<- already declared in UnityLightingCommon.cginc
		float _Hardness;

		struct Input {
			float2 uv_MainTex;
			float2 uv_SpecTex;
			float2 uv_NormTex;
		};

		void surf (Input IN, inout CustomSurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 s = tex2D (_SpecTex, IN.uv_SpecTex) * _SpecColor;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.SpecCol = s.rgb;
			o.Hardness = _Hardness;
			o.Normal = UnpackNormal(tex2D(_NormTex, IN.uv_NormTex));
		}
		ENDCG
	}
	FallBack "Diffuse"
}