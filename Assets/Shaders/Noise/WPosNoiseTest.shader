Shader "Custom/Noise/WPosNoiseTest" {

	Properties {
        _PositionScale ("Pos Scale", Float) = 1.0
        _TimeScale ("Time Scale", Float) = 1.0
        _DebugW ("Debug W", Float) = 0.0
        _Iterations ("Iterations", Int) = 1
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
            float _DebugW;
            uint _Iterations;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = fixed4(1,1,1,1);
                // col.rgb *= n41(float4(i.worldPos * _PositionScale, _Time.y * _TimeScale));
                // col.rgb *= perlin3(i.worldPos * _PositionScale);
                // col.rgb *= perlin4(float4(i.worldPos * _PositionScale, _DebugW));
                // col.rgb *= perlin4(float4(i.worldPos * _PositionScale, _Time.y * _TimeScale));
                // col.rgb *= clouds3(i.worldPos * _PositionScale, _Iterations);
                col.rgb *= clouds4(float4(i.worldPos * _PositionScale, _Time.y * _TimeScale), _Iterations);
				return col;
			}
			
			ENDCG
		}
	}
}