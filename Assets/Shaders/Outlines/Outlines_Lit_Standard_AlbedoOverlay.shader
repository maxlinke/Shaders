Shader "Custom/Outlines/Standard (Triplanar Albedo Overlay)" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB), Alpha (A)", 2D) = "white" {}
        [NoScaleOffset]_OverlayTex ("Overlay (RGB)", 2D) = "white" {}
        _OverlayOffset ("Overlay Offset (XYZ)", Vector) = (0,0,0,0)
        _OverlayScale ("Overlay Scale", Float) = 1.0
        [Toggle(MULTIPLY_OVERLAY)] _MultiplyOverlay ("Multiply Overlay", Int) = 0
        [NoScaleOffset] _MSOTex ("Metallic (R), Smoothness (G), Occlusion (B), Overlay Intensity (A)", 2D) = "white" {}
        _MMult ("Metallic Multiplier", Range(0, 1)) = 0.0
        _SMult ("Smoothness Multiplier", Range(0, 1)) = 0.5
        _OMult ("Occlusion Multiplier", Range(0, 1)) = 0.0
        _LMult ("Overlay Multiplier", Range(0, 1)) = 1.0
        [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _EmissionTex ("Emission (RGB)", 2D) = "black" {}
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
        #pragma shader_feature MULTIPLY_OVERLAY
        
		fixed4 _Color;
		sampler2D _MainTex;
        sampler2D _OverlayTex;
        sampler2D _MSOTex;
        sampler2D _BumpMap;
        sampler2D _EmissionTex;

        float _MMult;
        float _SMult;
        float _OMult;
        float _LMult;

        float4 _OverlayOffset;
        float _OverlayScale;

		struct Input {
			float2 uv_MainTex;
            float2 uv_OverlayTex;
			float3 worldPos;
			float3 worldNorm;
		};

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			o.worldNorm = UnityObjectToWorldNormal(v.normal);
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
            half3 ovrlBlend = IN.worldNorm * IN.worldNorm;
            ovrlBlend *= ovrlBlend;     // hardcoded pow(4) for a sharper transition
            ovrlBlend /= dot(ovrlBlend, float3(1,1,1));
            fixed4 ovrlX = tex2D(_OverlayTex, (IN.worldPos.zy / _OverlayScale) + _OverlayOffset.zy);
            fixed4 ovrlY = tex2D(_OverlayTex, (IN.worldPos.xz / _OverlayScale) + _OverlayOffset.xz);
            fixed4 ovrlZ = tex2D(_OverlayTex, (IN.worldPos.xy / _OverlayScale) + _OverlayOffset.xy);
            fixed4 ovrl = (ovrlX * ovrlBlend.x + ovrlY * ovrlBlend.y + ovrlZ * ovrlBlend.z);

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            fixed4 mso = tex2D(_MSOTex, IN.uv_MainTex);

            #ifdef MULTIPLY_OVERLAY
                ovrl = lerp(fixed4(1,1,1,1), ovrl, _LMult * mso.a);
			    o.Albedo = c.rgb * ovrl.rgb;
            #else
                ovrl = lerp(fixed4(0,0,0,0), ovrl, _LMult * mso.a);
                o.Albedo = lerp(c.rgb, ovrl.rgb * _Color.rgb, ovrl.a);
            #endif

			o.Alpha = c.a;
            fixed4 e = tex2D(_EmissionTex, IN.uv_MainTex) * _Color;
            o.Emission = e.rgb;
            o.Metallic = mso.r * _MMult;
            o.Smoothness = mso.g * _SMult;
            o.Occlusion = 1.0 - (mso.b * _OMult);
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
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
