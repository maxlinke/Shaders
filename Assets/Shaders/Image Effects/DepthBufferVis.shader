Shader "Custom/Image Effects/Depth Buffer Visualization"{

	Properties{
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
		_Linear ("Unaffected or linear", Range(0,1)) = 1.0
		_Power ("Power (depth^n)", Float) = 1.0
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

			float _Linear;
			float _Power;

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
				float rawDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));

				float linearDepth = Linear01Depth(rawDepth);
				float nearFar = _ProjectionParams.y / _ProjectionParams.z;
				linearDepth -= nearFar;
				linearDepth /= (1 - nearFar);
				linearDepth = 1 - linearDepth;

				fixed4 col;
				col.rgb = lerp(rawDepth, linearDepth, _Linear);
				col.a = 1.0;

				col = pow(col, _Power);

				return col;
			}
			ENDCG
		}
	}
}
