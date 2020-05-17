Shader "Custom/Outlines/Standard (Grunge)" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB), Alpha (A)", 2D) = "white" {}
        [NoScaleOffset]_GrungeTex ("Grunge (RGB)", 2D) = "white" {}
        _GrungeOffsetScale ("Grunge Offset (XYZ), Grunge Scale (W)", Vector) = (0,0,0,1)
        _GrungeStrength ("Grunge Strength", Range(0, 1)) = 1.0
        [Toggle(MULTIPLY_GRUNGE)] _MultiplyGrunge ("Multiply Grunge", Int) = 0
        [NoScaleOffset] _MSOTex ("Metallic (R), Smoothness (G), Occlusion (B), Inv. Grunge Intensity (A)", 2D) = "black" {}
        // _DebugM ("Debug M", Range(0, 1)) = 0
        // _DebugS ("Debug S", Range(0, 1)) = 0
        // _DebugO ("Debug O", Range(0, 1)) = 0
        // _DebugG ("Debug G", Range(0, 1)) = 0
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
		#pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma shader_feature MULTIPLY_GRUNGE
        
		fixed4 _Color;
		sampler2D _MainTex;
        sampler2D _GrungeTex;
        sampler2D _MSOTex;
        sampler2D _NormalTex;
        sampler2D _EmissionTex;

        // float _DebugM;
        // float _DebugS;
        // float _DebugO;
        // float _DebugG;

        float4 _GrungeOffsetScale;
        float _GrungeStrength;

		struct Input {
			float2 uv_MainTex;
            float2 uv_GrungeTex;
			float3 worldPos;
			float3 worldNorm;
		};

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			o.worldNorm = UnityObjectToWorldNormal(v.normal);
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
            half3 grungeBlend = IN.worldNorm * IN.worldNorm;
            grungeBlend *= grungeBlend;     // hardcoded pow(4) for a sharper transition
            grungeBlend /= dot(grungeBlend, float3(1,1,1));
            fixed4 gx = tex2D(_GrungeTex, (IN.worldPos.zy / _GrungeOffsetScale.w) + _GrungeOffsetScale.zy) ;
            fixed4 gy = tex2D(_GrungeTex, (IN.worldPos.xz / _GrungeOffsetScale.w) + _GrungeOffsetScale.xz) ;
            fixed4 gz = tex2D(_GrungeTex, (IN.worldPos.xy / _GrungeOffsetScale.w) + _GrungeOffsetScale.xy) ;
            fixed4 g = gx * grungeBlend.x + gy * grungeBlend.y + gz * grungeBlend.z;

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            fixed4 mso = tex2D(_MSOTex, IN.uv_MainTex);
            // mso.r = _DebugM;
            // mso.g = _DebugS;
            // mso.b = _DebugO;
            // mso.a = _DebugG;
            #ifdef MULTIPLY_GRUNGE
                g = lerp(fixed4(1,1,1,1), g, _GrungeStrength * (1.0 - mso.a));
			    o.Albedo = c.rgb * g.rgb;
            #else
                g = lerp(fixed4(0,0,0,0), g, _GrungeStrength * (1.0 - mso.a));
                o.Albedo = lerp(c.rgb, g.rgb, g.a);
            #endif

			o.Alpha = c.a;
            fixed4 e = tex2D(_EmissionTex, IN.uv_MainTex) * _Color;
            o.Emission = e.rgb;
            o.Metallic = mso.r;
            o.Smoothness = mso.g;
            o.Occlusion = 1.0 - mso.b;
            o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
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
