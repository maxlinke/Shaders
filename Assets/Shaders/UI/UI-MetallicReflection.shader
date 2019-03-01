Shader "Custom/UI/MetallicReflection" {

	Properties {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _EnvironmentMap ("Environment Map", CUBE) = "" {}

        [HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil ("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask ("Color Mask", Float) = 15
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader {

        Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass {
            Name "Default"

        	CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float4 normal	: NORMAL;
                float4 tangent	: TANGENT;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
				float4 objectPosition: TEXCOORD1;
                float4 worldPosition : TEXCOORD2;
                float3 worldNormal	 : TEXCOORD3;
                float3 tangentSpace0 : TEXCOORD4;
                float3 tangentSpace1 : TEXCOORD5;
                float3 tangentSpace2 : TEXCOORD6;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            samplerCUBE _EnvironmentMap;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            bool _UseClipRect;
			float4 _ClipRect;
            float4 _MainTex_ST;

            v2f vert (appdata_t v) {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.objectPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(v.vertex);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.color = v.color * _Color;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				float3 worldBitangent = cross(worldNormal, worldTangent) * tangentSign;
				OUT.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				OUT.worldNormal = worldNormal;
				OUT.tangentSpace0 = float3(worldTangent.x, worldBitangent.x, worldNormal.x);
				OUT.tangentSpace1 = float3(worldTangent.y, worldBitangent.y, worldNormal.y);
				OUT.tangentSpace2 = float3(worldTangent.z, worldBitangent.z, worldNormal.z);
                return OUT;
            }

            fixed4 frag (v2f IN) : SV_Target {
            	float3 texNormal = UnpackNormal(tex2D(_NormalMap, IN.texcoord));
            	float3 worldNormal;
            	worldNormal.x = dot(IN.tangentSpace0, texNormal);
            	worldNormal.y = dot(IN.tangentSpace1, texNormal);
            	worldNormal.z = dot(IN.tangentSpace2, texNormal);

            	float3 worldViewDir = normalize(UnityWorldSpaceViewDir(IN.worldPosition));
            	float3 worldReflection = reflect(worldNormal, worldViewDir);
            	worldReflection *= float3(-1, -1, -1);

                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                color *= texCUBE(_EnvironmentMap, worldReflection);

				if(_UseClipRect) color.a *= UnityGet2DClipping(IN.objectPosition.xy, _ClipRect);

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }

        ENDCG
        }
    }
}