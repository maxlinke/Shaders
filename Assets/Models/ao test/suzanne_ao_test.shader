Shader "Custom/suzanne_ao_test" {

	Properties {
        _Color ("Color", color) = (1,1,1,1)
		_AOTex ("AO Tex", 2D) = "white" {}
        _SpecularColor ("SpecCol", color) = (0.5, 0.5, 0.5, 1)
        _Hardness ("SpecHardness", Range(0,1)) = 0.5
	}

	SubShader {
        
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CustomBlinnPhong
        #include "../../Shaders/CustomLighting.cginc"

		#pragma target 3.0

        fixed4 _Color;
		sampler2D _AOTex;
        fixed4 _SpecularColor;
        half _Hardness;

		struct Input {
			float2 uv_AOTex;
		};

		void surf (Input IN, inout CustomSurfaceOutput o) {
			fixed4 ao = tex2D(_AOTex, IN.uv_AOTex);
            o.Albedo = _Color.rgb;
            o.Occlusion = ao.r;
            o.SpecCol = _SpecularColor;
            o.Hardness = _Hardness;
			o.Alpha = _Color.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
