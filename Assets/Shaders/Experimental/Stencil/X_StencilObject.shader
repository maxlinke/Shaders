Shader "Custom/Experimental/Stencil/X_StencilObject" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}

	SubShader {

		Tags { "RenderType" = "Opaque" "Queue" = "Geometry+2" }

		Stencil {
			Ref 37
			Comp Equal
			Pass Keep
		}

		CGPROGRAM
		#pragma surface surf Lambert
		//addshadow is not the solution to the shadow problem. meh.
		//but if i only do unlit stuff that's not an issue

		fixed4 _Color;
		sampler2D _MainTex;

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
