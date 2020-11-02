Shader "Custom/Outlines/ToonHair" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_HairAnisoTex ("Hair Aniso (RGB)", 2D) = "white" {}
        _MaxAnisoTexOffset ("Max Aniso Offset", Range(0, 1)) = 1.0
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// #pragma target 3.0

		sampler2D _HairAnisoTex;
        float _MaxAnisoTexOffset;

		struct Input {
			float2 uv_HairAnisoTex;
            float3 viewDir;
            float3 worldUp;
		};

		fixed4 _Color;

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldUp = normalize(mul(unity_ObjectToWorld, float4(0,1,0,0)).xyz);
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
            float anisoFakeDot = dot(IN.worldUp, IN.viewDir);
            float2 anisoUV = IN.uv_HairAnisoTex - float2(0, (_MaxAnisoTexOffset * anisoFakeDot));
			fixed4 c = tex2D (_HairAnisoTex, anisoUV) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
