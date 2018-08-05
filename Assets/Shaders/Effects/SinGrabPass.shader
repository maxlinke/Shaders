Shader "Custom/Effects/Sin GrabPass"{

	Properties{
		_Factor ("Factor", Float) = 4.0
	}

	SubShader{

		Tags { "Queue" = "Transparent+1" }

		GrabPass{
			"_BackgroundTex"
		}

		Pass{

			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			float _Factor;
			sampler2D _BackgroundTex;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 grabPos : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.pos);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 tex = tex2Dproj(_BackgroundTex, i.grabPos);
				fixed4 col = frac(sin(tex * UNITY_PI * _Factor));
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
