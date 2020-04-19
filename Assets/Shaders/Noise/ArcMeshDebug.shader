Shader "Custom/Noise/ArcMeshDebug" {

	Properties {
		_Color ("Color", Color) = (1.0, 0.8, 0.6, 1.0)
		_BackfaceColor ("Backface Color", Color) = (0.6, 0.8, 1.0, 1.0)
        _Extrusion ("Normal Extrusion", Float) = 0.1
	}

	SubShader {

		Tags { "RenderType"="Opaque" }

        Cull Off

        Pass {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            fixed4 _BackfaceColor;
            float _Extrusion;

            float4 vert (float4 vertex : POSITION, float4 normal : NORMAL) : SV_POSITION {
                return UnityObjectToClipPos(vertex + _Extrusion * normal);
            }

            fixed4 frag (fixed face : VFACE) : SV_TARGET {
                return face * _Color + (1 - face) * _BackfaceColor;
            }

            ENDCG

        }
		
	}

}
