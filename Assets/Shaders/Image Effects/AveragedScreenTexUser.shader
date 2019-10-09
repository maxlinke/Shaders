Shader "Custom/Image Effects/Averaged Screen Tex User"{

	Properties {
        _A ("Normal Blend Bound A", Range(0, 1)) = 0
        _B ("Normal Blend Bound B", Range(0, 1)) = 1
    }

	SubShader {

		Tags { "Queue"="Transparent" }
		LOD 100

        ZTest LEqual
        ZWrite Off
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha

		Pass {

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

            sampler2D _AveragedScreenTex;
            float _A;
            float _B;

			struct appdata {
				float4 vertex : POSITION;
                float4 normal : NORMAL;
			};

			struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 screenPos : TEXCOORD2;
				UNITY_FOG_COORDS(3)
			};
			
			v2f vert (appdata v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
                float4 sPos = ComputeScreenPos(o.pos);
                o.screenPos = sPos.xy / max(sPos.w, 0.001);;
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = tex2D(_AveragedScreenTex, i.screenPos.xy);
                UNITY_APPLY_FOG(i.fogCoord, col);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
                float viewDot = dot(viewDir, normalize(i.worldNormal));
                float blend = saturate((abs(viewDot) - _A) / (_B - _A));
                col.a *= blend;
				return col;
			}
			ENDCG
		}
	}
}
