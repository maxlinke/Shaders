Shader "Custom/DiffUV" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Custom

		sampler2D _MainTex;
		fixed4 _Color;

		inline half4 LightingCustom (SurfaceOutput s, half3 lightDir, half atten) {
			lightDir = normalize(lightDir);
			s.Normal = normalize(s.Normal);
			half diff = saturate(dot(lightDir, s.Normal));
			half4 c;
			c.rgb = diff * atten * s.Albedo * _LightColor0.rgb;
			c.a = s.Alpha;
			return c;
		}

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
