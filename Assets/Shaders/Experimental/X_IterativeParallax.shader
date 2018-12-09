Shader "Custom/Experimental/X_IterativeParallax"{

	Properties{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Dist ("Distance Between Layers", Range(-1, 1)) = -0.5
		_Iterations ("Number Of Layers", int) = 4
	}

	SubShader{

		Blend One One
		ZWrite Off

		Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
		LOD 100

		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Dist;
			fixed4 _Color;
			int _Iterations;

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 tanViewDir : TEXCOORD1;
			};
			
			v2f vert (appdata_full v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				float3x3 obj2tan = float3x3(
					v.tangent.xyz,
					cross(v.normal, v.tangent.xyz) * v.tangent.w,
					v.normal
				);
				o.tanViewDir = mul(obj2tan, ObjSpaceViewDir(v.vertex));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				fixed4 col = tex2D(_MainTex, i.uv);
				i.tanViewDir = normalize(i.tanViewDir);
				for(int count = 1; count < _Iterations; count++){
					float2 newUV = i.uv + (count * i.tanViewDir.xy * _Dist);
					col += tex2D(_MainTex, newUV) * (1.0 - (float)count / _Iterations);
				}
				return col * _Color;
			}

			ENDCG
		}
	}
}
