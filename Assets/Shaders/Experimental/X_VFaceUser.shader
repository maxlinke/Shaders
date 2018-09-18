Shader "Custom/Experimental/X_VFaceUser" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BackfaceColor ("Backface Color", Color) = (1.0, 0.5, 0.25, 1)
	}

	SubShader {

		Cull Off

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			fixed face : VFACE;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _BackfaceColor;

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed faceStep = step(0.5, IN.face);
			fixed4 c = faceStep * tex;
			fixed4 e = (1 - faceStep) * _BackfaceColor;
			o.Albedo = c.rgb;
			o.Emission = e.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
