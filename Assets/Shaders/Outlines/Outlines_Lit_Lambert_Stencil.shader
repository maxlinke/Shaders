Shader "Custom/Outlines/Lambert (Stencil)" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        _OutlineTint ("Outline Tint", Color) = (0,0,0,0)
        _OutlineWidth ("Outline Width", Float) = 0.1
        [Toggle(FIXED_OUTLINE_WIDTH)] _ToggleFixedOutlineWidth ("Fixed Outline Width", Int) = 0
        [PerRendererData] _Scale ("Scale", Vector) = (1,1,1,1)
        _StencilID ("Stencil ID", int) = 0
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200

        // Stencil {
        //     Ref [_StencilID]
        //     Comp Always
        //     Pass Replace
        // }
		
		CGPROGRAM
		#pragma surface surf Lambert
        
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

        Pass {          // using this pass at least sometimes gives outlines between objects. doing it in the surface program never does..

            Stencil {
                Ref [_StencilID]
                Comp Always
                Pass Replace
            }
            
            ZTest LEqual
            ZWrite Off
            ColorMask 0

        }

        Pass {      // apparently doesn't happen in deferred

            Stencil {
                Ref [_StencilID]
                Comp NotEqual
                Pass Zero
            }

            CGPROGRAM

            #pragma vertex simpleOutlineVert
            #pragma fragment simpleOutlineFrag
            #pragma multi_compile_fog
            #pragma shader_feature FIXED_OUTLINE_WIDTH

            #include "UnityCG.cginc"
            #include "Outlines.cginc"

            ENDCG

        }

        // Pass {           // doesn't work..

        //     Tags { "LightMode" = "Deferred" }

        //     Stencil {
        //         Ref [_StencilID]
        //         Comp NotEqual
        //         Pass Zero
        //     }

        //     CGPROGRAM

        //     #pragma exclude_renderers nomrt

        //     #pragma vertex simpleOutlineVert
        //     #pragma fragment simpleOutlineFrag
        //     #pragma multi_compile_fog
        //     #pragma shader_feature FIXED_OUTLINE_WIDTH
        //     #define OUTLINES_DEFERRED

        //     #include "UnityCG.cginc"
        //     #include "Outlines.cginc"

        //     ENDCG

        // }

	}
	FallBack "Diffuse"
}
