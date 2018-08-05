Shader "Custom/Wireframe/UnlitWireframeWithBorder"{

	Properties{
		_Color ("Color", Color) = (1,1,1,1)
		_WireColor ("Wireframe Color", Color) = (0,0,0,1)
		_WireWidth ("Wire Width", Range(0,10)) = 1.0
		_WireSmoothing ("Wire Smoothing", Range(0,10)) = 0.0
		_BorderThickness ("Border Thickness", Range(0,10)) = 1.0
		_Scale ("Scale", Vector) = (1,1,1,1)
	}

	SubShader{

		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass{

			CGPROGRAM
			#pragma vertex wireVert
			#pragma fragment wireFrag
			#pragma geometry wireGeom
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "UnlitWireframes.cginc"

			ENDCG
		}

		Pass{

			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			fixed4 _WireColor;
			float _BorderThickness;
			float4 _Scale;

			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				UNITY_FOG_COORDS(0)
			};
			
			v2f vert (appdata v){
				v2f o;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float camDist = length(_WorldSpaceCameraPos - worldPos);
				v.vertex.xyz += (v.normal / _Scale * _BorderThickness * camDist / _ScreenParams.y);
				o.pos = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				fixed4 col = _WireColor;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}

			ENDCG

		}
	}
}
