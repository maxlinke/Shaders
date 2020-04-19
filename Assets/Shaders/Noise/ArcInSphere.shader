Shader "Unlit/ArcInSphere" {

    // requires a mesh starting at (0,0,0) and going in z direction to (0,0,1)


	Properties {
        _Color ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MaxThickness ("Maximum Thickness", Float) = 0.1

	}
	
	SubShader {
	
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		LOD 100

        Cull Front
        Blend One One
        ZTest LEqual
        ZWrite Off

		Pass {
		
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
			};

            fixed4 _Color;
			float _MaxThickness;

            float3 bezierPoint (float3 bStart, float3 bEnd, float3 bCtrl, float bT) {
                float bTInv = 1.0 - bT;
                return bCtrl + (bTInv * bTInv * (bStart - bCtrl)) + (bT * bT * (bEnd - bCtrl));
            }

            float3 bezierDerivative (float3 bStart, float3 bEnd, float3 bCtrl, float bT) {
                return (2.0 * (1.0 - bT) * (bCtrl - bStart)) + (2 * bT * (bEnd - bCtrl));
            }

			v2f vert (appdata v) {
                // quadratic bezier curve
                float3 bStart = float3(0,0,0);
                float3 bEnd = float3(1,0,1);
                float3 bCtrl = float3(0,0,1);
                float bT = v.vertex.z;
                float3 bPos = bezierPoint(bStart, bEnd, bCtrl, bT);
                // coordinate system
                float3 bFwd = bezierDerivative(bStart, bEnd, bCtrl, bT);
                float3 bA = normalize(cross(bFwd, bezierDerivative(bStart, bEnd, bCtrl, bT - 0.01)));
                float3 bB = normalize(cross(bFwd, bA));
                float3x3 rot = transpose(float3x3(bA, bB, bFwd));


                // do the stuff here...
                float3 finalVertex = bPos + _MaxThickness * mul(rot, v.normal.xyz);
				v2f o;
				o.pos = UnityObjectToClipPos(finalVertex);
                o.worldPos = mul(unity_ObjectToWorld, finalVertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				return _Color;
			}
			
			ENDCG
		}
	}
}
