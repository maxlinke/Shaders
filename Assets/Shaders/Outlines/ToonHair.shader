Shader "Custom/Outlines/ToonHair" {

	Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
        _Hardness ("Specular Hardness", Range(0,1)) = 0.5
        _Indirect ("Indirect", Color) = (0.5, 0.5, 0.5, 1)

		_HairAnisoTex ("Hair Aniso (RGB)", 2D) = "white" {}
        _MaxAnisoTexOffset ("Max Aniso Offset", Range(0, 1)) = 1.0
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200

        Pass {

            Tags {"LightMode" = "ForwardBase"}
		
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityShadowLibrary.cginc"

            sampler2D _HairAnisoTex;
            float4 _HairAnisoTex_ST;
            
            float _MaxAnisoTexOffset;

            fixed4 _Color;
            fixed4 _SpecColor;
            float _Hardness;
            fixed4 _Indirect;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                float3 worldUp : TEXCOORD4;
                LIGHTING_COORDS(5, 6)
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _HairAnisoTex);
                o.lightDir = WorldSpaceLightDir(v.vertex);
                float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - wPos);
                o.worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
                o.worldUp = normalize(mul(unity_ObjectToWorld, float4(0,1,0,0)).xyz);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_TARGET {
                float anisoFakeDot = dot(i.worldUp, i.viewDir);
                float2 anisoUV = i.uv - float2(0, (_MaxAnisoTexOffset * anisoFakeDot));
                float aniso = tex2D(_HairAnisoTex, anisoUV).r;
                float atten = LIGHT_ATTENUATION(i);
                float3 lightDir = normalize(i.lightDir);
                float3 worldNormal = normalize(i.worldNormal);
                float3 halfVec = normalize(lightDir + i.viewDir);
                float spec = pow(saturate(dot(halfVec, worldNormal)), _Hardness * 128.0);
                fixed4 directCol = fixed4(1,1,1,1);
                directCol.rgb = _SpecColor.rgb * aniso * spec * atten;
                directCol.rgb += _Color.rgb * saturate(dot(worldNormal, lightDir)) * atten;
                fixed4 indirectCol = fixed4(1,1,1,1);
                indirectCol.rgb = _Indirect.rgb * aniso;
                indirectCol.rgb += _Color.rgb * ShadeSH9(half4(worldNormal, 1));
                return directCol + indirectCol;
                // return fixed4(ShadeSH9(half4(worldNormal, 1)), 1);
            }
            ENDCG

        }
	}
	FallBack "Diffuse"
}
