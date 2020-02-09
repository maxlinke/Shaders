Shader "Custom/Noise/UVNoiseTest" {

	Properties {
        _NoiseScale ("Noise Scale", Float) = 1.0
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
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

            float _NoiseScale;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv * _NoiseScale - _NoiseScale / 2.0;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = fixed4(1,1,1,1);
                // col.rgb = n21(i.uv);
                // col.rgb = perlin2(i.uv);
                // col.rgb = perlin1(i.uv.x);
                col.rgb = clouds2(i.uv, 4);
                // col.rgb = clouds1(i.uv.x, 4);
				return col;
			}
			
			ENDCG
		}
	}
}
