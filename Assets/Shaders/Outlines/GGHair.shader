Shader "Custom/GGHair" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal] _BumpMap ("Normal Map", 2D) = "bump"  {}

        _HairSpecTex ("Hair Spec Texture", 2D) = "white" {}
        _HairAnisoTex ("Hair Aniso Gradient", 2D) = "white" {}
        _MaxAnisoOffset ("Max Aniso Offset", Range(0, 1)) = 1.0

        _HairEmission ("Hair Emission", Color) = (0.5,0.5,0.5,1)
        _HairSmoothness ("Hair Smoothness", Range(0, 1)) = 0.5
        _HairMetallic ("Hair Metallic", Range(0, 1)) = 0.0
	}

	SubShader {
        
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
        // #include "GGHair.cginc"
		#pragma surface surf Standard fullforwardshadows vertex:vert

		#pragma target 3.5

		sampler2D _MainTex;
        sampler2D _HairSpecTex;
        sampler2D _HairAnisoTex;
        sampler2D _BumpMap;

		struct Input {
            float2 uv_HairAnisoTex;
			float2 uv2_MainTex;
            float2 uv2_HairSpecTex;
            float2 uv2_BumpMap;
            float3 viewDir;
            float3 worldUp;
		};

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldUp = normalize(mul(unity_ObjectToWorld, float4(0,1,0,0)).xyz);
        }

		fixed4 _Color;
        fixed4 _HairEmission;

        float _MaxAnisoOffset;
        float _HairSmoothness;
        float _HairMetallic;

        float GetAniso (Input IN) {
            float anisoDot = dot(IN.worldUp, IN.viewDir);
            float2 anisoUV = IN.uv_HairAnisoTex - float2(0, (_MaxAnisoOffset * anisoDot));
            return tex2D(_HairAnisoTex, anisoUV).r;
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = _Color * tex2D(_MainTex, IN.uv2_MainTex);
            o.Metallic = _HairMetallic;
            o.Smoothness = _HairSmoothness;
            float spec = GetAniso(IN) * tex2D(_HairSpecTex, IN.uv2_HairSpecTex).r;
            o.Emission = _HairEmission.rgb * spec;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv2_BumpMap));
            o.Alpha = 1.0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
