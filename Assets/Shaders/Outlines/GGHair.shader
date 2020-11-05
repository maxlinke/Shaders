Shader "Custom/Outlines/GGHair" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB), AO (A)", 2D) = "white" {}
        [Normal] _BumpMap ("Normal Map", 2D) = "bump"  {}

        _HairSpecTex ("Hair Spec Texture", 2D) = "white" {}
        _HairAnisoTex ("Hair Aniso Gradient", 2D) = "white" {}
        _MaxAnisoOffset ("Max Aniso Offset", Range(0, 1)) = 1.0

        _HairEmission ("Hair Emission", Color) = (0.5,0.5,0.5,1)
        _HairSmoothness ("Hair Smoothness", Range(0, 1)) = 0.5
        _HairMetallic ("Hair Metallic", Range(0, 1)) = 0.0
        
        _OutlineTint ("Outline Tint", Color) = (0,0,0,0)
        _OutlineWidth ("Outline Width", Float) = 0.1
        [Toggle(FIXED_OUTLINE_WIDTH)] _ToggleFixedOutlineWidth ("Fixed Outline Width", Int) = 0
        [PerRendererData] _Scale ("Scale", Vector) = (1,1,1,1)
	}

	SubShader {
        
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows vertex:vert

		#pragma target 3.5

		sampler2D _MainTex;
        sampler2D _HairSpecTex;
        sampler2D _HairAnisoTex;
        sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
            float2 uv_HairSpecTex;
            float2 uv_BumpMap;
            float2 uv2_HairAnisoTex;
            // float3 viewDir;          // for some reason, this is nonsense when using a normal map in 5.6...
            float3 worldPos;
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

        float GetAniso (Input IN, float3 viewDir) {
            float anisoDot = dot(IN.worldUp, viewDir);
            float2 anisoUV = IN.uv2_HairAnisoTex - float2(0, (_MaxAnisoOffset * anisoDot));
            return tex2D(_HairAnisoTex, anisoUV).r;
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = _Color * tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Occlusion = c.a;
            float3 viewDir = normalize(_WorldSpaceCameraPos - IN.worldPos);
            // float3 viewDir = IN.viewDir;
            float spec = GetAniso(IN, viewDir) * tex2D(_HairSpecTex, IN.uv_HairSpecTex).r;
            o.Emission = _HairEmission.rgb * spec * c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Metallic = _HairMetallic;
            o.Smoothness = _HairSmoothness;
            o.Alpha = 1.0;

            // o.Albedo = fixed3(0,0,0);
            // o.Metallic = 0;
            // o.Smoothness = 0;
            // o.Occlusion = 0;
            // o.Emission = viewDir;
		}

		ENDCG

        Pass {
            
            Tags { "LightMode" = "ForwardBase" }

            Cull Front

            CGPROGRAM

            #pragma vertex simpleOutlineVert
            #pragma fragment simpleOutlineFrag
            #pragma multi_compile_fog
            #pragma shader_feature FIXED_OUTLINE_WIDTH
            #include "Outlines.cginc"

            ENDCG

        }

        Pass {

            Tags { "LightMode" = "Deferred" }

            Cull Front

            CGPROGRAM

            #pragma exclude_renderers nomrt

            #pragma vertex simpleOutlineVert
            #pragma fragment simpleOutlineFrag
            #pragma multi_compile_fog
            #pragma multi_compile ___ UNITY_HDR_ON
            #pragma shader_feature FIXED_OUTLINE_WIDTH
            #define OUTLINES_DEFERRED
            #include "Outlines.cginc"

            ENDCG

        }
	}
	FallBack "Diffuse"
}
