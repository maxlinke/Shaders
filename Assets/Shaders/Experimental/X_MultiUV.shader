Shader "Custom/Experimental/X_MultiUV" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
        _SecTex ("Secondary Texture", 2d) = "white" {}
        _Lerp ("Lerp", Range(0,1)) = 0.5
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
        sampler2D _SecTex;

		struct Input {
            float2 uv_MainTex;
            float2 uv2_SecTex;
		};

		fixed4 _Color;
        float _Lerp;

		void surf (Input IN, inout SurfaceOutput o) {
            fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 secTex = tex2D(_SecTex, IN.uv2_SecTex);
			fixed4 c = _Color * lerp(mainTex, secTex, _Lerp);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
        }

		ENDCG
	}
	FallBack "Diffuse"
}
