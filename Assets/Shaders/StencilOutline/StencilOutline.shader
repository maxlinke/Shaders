Shader "Custom/StencilOutline" {
	
    Properties {
		_Color ("Color", Color) = (1,1,1,1)
        _ConstantThickness ("Constant Thickness", Range(0,1)) = 1.0
        _BorderThickness ("Border Thickness", Range(0,10)) = 1.0
		_Scale ("Scale", Vector) = (1,1,1,1)
        _StencilID ("Stencil ID", int) = 0
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 100

        Pass {

            Tags { "Queue" = "Geometry+1" }

            Stencil {
                Ref [_StencilID]
                Comp Always
                Pass Replace
            }

            ZTest LEqual
            ZWrite Off
            ColorMask 0

        }

		Pass {

            Tags { "Queue" = "Geometry+2" }

            Stencil {
                Ref [_StencilID]
                Comp NotEqual
            }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

            fixed4 _Color;
            float _ConstantThickness;
			float _BorderThickness;
			float4 _Scale;            

			struct appdata {
				float4 vertex : POSITION;
                float4 normal : NORMAL;
			};

			struct v2f {
                float4 pos : SV_POSITION;
				UNITY_FOG_COORDS(1)
			};
			
			v2f vert (appdata v) {
				v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float camDist = length(_WorldSpaceCameraPos - worldPos);
                float finalMultiplier = lerp(1.0, camDist / _ScreenParams.y, _ConstantThickness);
                o.pos = UnityObjectToClipPos(v.vertex.xyz + (v.normal / _Scale * _BorderThickness * finalMultiplier));
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
                fixed4 col = _Color;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
