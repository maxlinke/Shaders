Shader "Custom/Experimental/X_GG" {

    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        
        _OutlineTint ("Outline Tint", Color) = (0,0,0,0)
        _OutlineWidth ("Outline Width", Float) = 0.1
        [Toggle(FIXED_OUTLINE_WIDTH)] _ToggleFixedOutlineWidth ("Fixed Outline Width", Int) = 0
        [PerRendererData] _Scale ("Scale", Vector) = (1,1,1,1)
    }
	
    SubShader {
	
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
		
        #pragma surface surf CustomGGDiffuse
        #pragma target 3.0
        #include "../CustomLighting.cginc"

        fixed4 _Color;
        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

        inline half4 LightingCustomGGDiffuse (CustomSurfaceOutput s, half3 viewDir, UnityGI gi) {
            // can put these two in one vector, since both do the same thing
            half nDotL = dot(s.Normal, gi.light.dir);
            nDotL = (1.0 + nDotL) / 2.0;
            // nDotL *= nDotL;              // < less wraparound but also less flattening of the lighting...
            half nDotV = dot(s.Normal, viewDir);
            nDotV = (1.0 + nDotV) / 2.0;
            // also add specular stuff (schlick?)
            half3 diff = gi.light.color * (nDotV * nDotL);
            diff += (gi.indirect.diffuse * s.Occlusion);
            half4 c;
            c.rgb = s.Albedo * diff;
            c.a = s.Alpha;
            return c;
        }

        inline void LightingCustomGGDiffuse_GI (CustomSurfaceOutput s, UnityGIInput data, inout UnityGI gi) {
            gi = UnityGlobalIllumination(data, 1.0, s.Normal);
        }

        void surf (Input IN, inout CustomSurfaceOutput o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
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
            #include "../Outlines/Outlines.cginc"

            ENDCG

        }
    }

    FallBack "Diffuse"
}
