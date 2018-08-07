Shader "Custom/Z_texArrayTest"{

	Properties{
		_Color ("Color", Color) = (1,1,1,1)
		_TexArray ("Textures", 2DArray) = "" {}
		_ZCoord ("Z Coordinate", Float) = 0.0
	}

	SubShader{

		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
//			#pragma require 2darray
			
			#include "UnityCG.cginc"

			UNITY_DECLARE_TEX2DARRAY(_TexArray);
			float _ZCoord;
			fixed4 _Color;

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 vertex : SV_POSITION;
				float3 uv : TEXCOORD0;
			};
			
			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = float3(v.uv, _ZCoord);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				fixed4 col = UNITY_SAMPLE_TEX2DARRAY(_TexArray, i.uv) * _Color;
				return col;
			}
			ENDCG
		}
	}
}
