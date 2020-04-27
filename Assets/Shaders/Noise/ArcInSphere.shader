Shader "Unlit/ArcInSphere" {

	Properties {
        _Color ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _GlowColor ("Glow Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MaxThickness ("Maximum Thickness", Float) = 0.1
        _ArcFrequency ("Arc Frequency", Float) = 2.0
        _ArcDrift ("Arc Drift", Float) = 0.1
        _EndDrift ("End Drift", Float) = 0.1
        _MinLat ("Minimum End Point Latitude", Range(-1, 1)) = 0.2
        _MaxLat ("Maximum End Point Latutude", Range(-1, 1)) = 0.9
        _MaxCoilDisplace ("Max Coil Displacement", Float) = 0.2
        _CoilLength ("Coil Length", Float) = 1.0
        _CoilLengthScatter ("Coil Length Scatter", Float) = 0.2
        _NoiseStrength ("Noise Strength", Float) = 0.1
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
            #include "Arcs.cginc"

			v2f vert (appdata v) {
                float3 arcVertex = calculateVertexPosition(v, 1.0);
				v2f o;
				o.pos = UnityObjectToClipPos(arcVertex);
                o.worldPos = mul(unity_ObjectToWorld, arcVertex).xyz;
                o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
                fixed4 c = _Color * sqrt(i.uv.y);
				return c;
			}
			
			ENDCG
		}

        Pass {
		
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
            #include "Arcs.cginc"

			v2f vert (appdata v) {
                float3 arcVertex = calculateVertexPosition(v, 1.333);
				v2f o;
				o.pos = UnityObjectToClipPos(arcVertex);
                o.worldPos = mul(unity_ObjectToWorld, arcVertex).xyz;
                o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
                fixed4 c = _GlowColor * sqrt(i.uv.y);
				return c;
			}
			
			ENDCG
		}
	}
}
