Shader "Custom/Experimental/X_WPosNormal" {

	Properties {
		_Switch ("Switch (0=Normal, 1=WPosNormal)", Range(0, 1)) = 0.0
	}
	
	SubShader {
	
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
                float4 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
				UNITY_FOG_COORDS(1)
			};

			float _Switch;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = fixed4(1,1,1,1);
                float3 dxWPos = ddx(i.worldPos);
                float3 dyWPos = ddy(i.worldPos);
                float3 wPosNormal = normalize(cross(dyWPos, dxWPos));
                col.rgb = wPosNormal;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			
			ENDCG
		}
	}
}
