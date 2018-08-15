Shader "Custom/Image Effects/Luminance to gradient"{

	Properties{
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset] _Gradient ("Gradient", 2D) = "white" {}
	}

	SubShader{

		Cull Off
		ZWrite Off
		ZTest Always

		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Gradient;

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
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				fixed4 tex = tex2D(_MainTex, i.uv);
				half lum = 0.299 * tex.r + 0.587 * tex.g + 0.114 * tex.b;
				return tex2D(_Gradient, half2(lum, 0.5));
			}
			ENDCG
		}
	}
}
