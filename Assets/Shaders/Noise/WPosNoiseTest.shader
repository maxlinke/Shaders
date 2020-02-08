Shader "Custom/Noise/WPosNoiseTest" {

	Properties {
        _PositionScale ("Pos Scale", Float) = 1.0
        _TimeScale ("Time Scale", Float) = 1.0
	}
	
	SubShader {
	
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "Noise.cginc"

			struct appdata {
				float4 vertex : POSITION;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
			};

            float _PositionScale;
            float _TimeScale;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = fixed4(1,1,1,1);
                // col.rgb *= n41p(float4(i.worldPos * _PositionScale, _Time.y * _TimeScale));
                col.rgb *= n41(float4(i.worldPos * _PositionScale, _Time.y * _TimeScale));
				return col;
			}
			
			ENDCG
		}
	}
}