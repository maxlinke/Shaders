﻿Shader "Custom/Decal/surf_DecalSpecular" {

	Properties{
		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
		_Shininess ("Shininess", Range(0.01, 1)) = 0.078125
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
	}

	SubShader{

		Tags{ "Queue" = "AlphaTest" "RenderType" = "Opaque" }

		CGPROGRAM
		#pragma surface surf BlinnPhong alphatest:_Cutoff

		sampler2D _MainTex;
		fixed4 _Color;
		half _Shininess;

		struct Input{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o){
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb * _Color.rgb;
			o.Gloss = tex.a;
			o.Alpha = tex.a * _Color.a;
			o.Specular = _Shininess;
		}

		ENDCG

	}
}