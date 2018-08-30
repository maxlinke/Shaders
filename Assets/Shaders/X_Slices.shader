Shader "Custom/X_Slices"{

	Properties{
		_Offset ("Offset Vector", Vector) = (0,0,0,0)
		_Direction ("Direction Vector", Vector) = (0,1,0,0)
	}

	SubShader{

		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			half4 _Offset;
			half4 _Direction;

			struct appdata{
				float4 vertex : POSITION;
			};

			struct v2f{
				float4 vertex : SV_POSITION;
				float sliceValue : TEXCOORD1;
			};
			
			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.sliceValue = dot(v.vertex.xyz - _Offset, _Direction.xyz);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				fixed4 col = fixed4(1,1,1,1);
				col.rgb = step(i.sliceValue, 0);
				return col;
			}
			ENDCG
		}
	}
}
