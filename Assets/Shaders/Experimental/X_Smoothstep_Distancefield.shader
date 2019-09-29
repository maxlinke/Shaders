Shader "Custom/Experimental/X_Smoothstep_Distancefield" {

	Properties {
		_MainTex ("Texture", 2D) = "white" {}
        _Middle ("Middle", Range(0, 1)) = 0.5
        _Delta ("Delta", Range(0, 1)) = 1.0
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float _Middle;
            float _Delta;
			
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = tex2D(_MainTex, i.uv);
                float x = (col.r + col.b + col.g) / 3.0;
                float halfDelta = _Delta / 2.0;
                float smooth = smoothstep(_Middle - halfDelta, _Middle + halfDelta, x);
				return lerp(fixed4(0,0,0,1), fixed4(1,1,1,1), smooth);
			}

			ENDCG
		}
	}
}
