Shader "Custom/Outlines/Standard" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB), Alpha (A)", 2D) = "white" {}
        [NoScaleOffset] _MSOTex ("Metallic (R), Smoothness (G), Occlusion (B)", 2D) = "black" {}
        // _DebugM ("Debug M", Range(0, 1)) = 0
        // _DebugS ("Debug S", Range(0, 1)) = 0
        // _DebugO ("Debug O", Range(0, 1)) = 0
        [NoScaleOffset] _NormalTex ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _EmissionTex ("Emission (RGB)", 2D) = "black" {}
        _OutlineWidth ("Outline Width", Float) = 0.1
        [Toggle(FIXED_OUTLINE_WIDTH)] _ToggleFixedOutlineWidth ("Fixed Outline Width", Int) = 0
        [PerRendererData] _Scale ("Scale", Vector) = (1,1,1,1)
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
        
		fixed4 _Color;
		sampler2D _MainTex;
        sampler2D _MSOTex;
        sampler2D _NormalTex;
        sampler2D _EmissionTex;

        // float _DebugM;
        // float _DebugS;
        // float _DebugO;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
            fixed4 e = tex2D(_EmissionTex, IN.uv_MainTex) * _Color;
            o.Emission = e.rgb;
            fixed4 mso = tex2D(_MSOTex, IN.uv_MainTex);
            o.Metallic = mso.r;
            o.Smoothness = mso.g;
            o.Occlusion = 1.0 - mso.b;
            // o.Metallic = _DebugM;
            // o.Smoothness = _DebugS;
            // o.Occlusion = _DebugO;
            o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
		}

		ENDCG

        Pass {      // apparently doesn't happen in deferred
            
            Cull Front

            CGPROGRAM

            #pragma vertex simpleOutlineVert
            #pragma fragment simpleOutlineFrag
            #pragma multi_compile_fog
            #pragma shader_feature FIXED_OUTLINE_WIDTH

            #include "UnityCG.cginc"
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
            #pragma shader_feature FIXED_OUTLINE_WIDTH
            #define OUTLINES_DEFERRED

            #include "UnityCG.cginc"
            #include "Outlines.cginc"

            ENDCG

        }

	}
	FallBack "Diffuse"
}
