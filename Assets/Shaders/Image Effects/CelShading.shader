Shader "Custom/Image Effects/CelShading"{

	//TODO stuff more based on depth... like line weight (radius) both on "absolute" distance and delta distance
	//also variable threshold i think...

	Properties{
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
		_Threshold ("Threshold", Range(0,1)) = 0.1
		_Radius ("Radius", Range(0,10)) = 2.0
	}

	SubShader{

		Cull Off
		ZWrite Off
		ZTest Always

		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;

			float _Threshold;
			float _Radius;

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			float deltaDepth (float2 uv, float radius) {
				float centerDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv));

				float maxDelta = 0;
				for (int i=0; i<4; i++) {
					float j = i * UNITY_TWO_PI / 4.0;
					float2 uvOffset = float2(cos(j), sin(j));
					uvOffset *= radius;
					uvOffset /= _ScreenParams.xy;
					float newDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv + uvOffset));
					float delta = abs(centerDepth - newDepth);
					maxDelta = max(maxDelta, delta);
				}
				return maxDelta;

//				float ix = 1.0 / _ScreenParams.x;
//				float iy = 1.0 / _ScreenParams.y;
//				float maxDelta = 0;
//				maxDelta = max(maxDelta, abs(centerDepth - UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv + float2(0, iy)))));
//				maxDelta = max(maxDelta, abs(centerDepth - UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv - float2(0, iy)))));
//				maxDelta = max(maxDelta, abs(centerDepth - UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv + float2(ix, 0)))));
//				maxDelta = max(maxDelta, abs(centerDepth - UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv - float2(ix, 0)))));
//				return maxDelta;

//				return centerDepth;
			}
			
			v2f vert (appdata v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y < 0) o.uv.y = 1 - o.uv.y;	//does this work? i dont know... i just copy-pasted code :P
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
//				float rawDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				fixed4 tex = tex2D(_MainTex, i.uv);
				float s = step(deltaDepth(i.uv, _Radius), _Threshold);
				fixed4 col = (s * tex) + ((1-s) * fixed4(0,0,0,0));
//				fixed4 col = deltaDepth(i.uv, _Radius);
//				fixed4 col = rawDepth;
				return col;
			}
			ENDCG
		}
	}
}
