Shader "Custom/Image Effects/Depth Buffer Visualization"{

	Properties{
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
	}

	SubShader{

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

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
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
				fixed4 col = tex2D(_MainTex, i.uv);
//				float depth = DecodeFloatRG(tex2D(_CameraDepthTexture, i.uv));
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
//				depth = Linear01Depth(depth);
				col = depth;
//				col = frac(depth);
				col.a = 1.0;
				return col;
			}
			ENDCG
		}
	}
}
