Shader "Custom/DiffUV (Emissive)" {
	
    Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        _EmissionColor ("Emission Color", Color) = (0,0,0,1)
        _EmissionTex ("Emission (RGB)", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CustomLambert //fullforwardshadows
		#include "CustomLighting.cginc"

		sampler2D _MainTex;
        sampler2D _EmissionTex;
		fixed4 _Color;
        fixed4 _EmissionColor;

		struct Input {
			float2 uv_MainTex;
            float2 uv_EmissionTex;
		};

		void surf (Input IN, inout CustomSurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
            o.Emission = tex2D(_EmissionTex, IN.uv_EmissionTex).rgb * _EmissionColor.rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
