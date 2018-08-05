Shader "Custom/Z_Gun3"{

	Properties{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader{

		Tags { "Queue" = "AlphaTest+1" }
		LOD 100

		Pass{

			ColorMask 0
			ZTest Always
			ZWrite On

		}

		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
