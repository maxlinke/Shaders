Shader "Custom/Noise/Lightning" {

    // meshrenderer needs its bounds set via script... 

	Properties {
        _Color ("Main Color", Color ) = (1.0, 1.0, 1.0, 1.0)
        _GlowColor ("Glow Color", Color) = (0.5, 0.5, 1.0, 1.0)
		_ArcFrequency ("Arc Frequency", Float) = 2.0
        _MaxArcDisplace ("Max Arc Displacement", Float) = 0.2
        _MaxCoilDisplace ("Max Coil Displacement", Float) = 0.2
        _CoilLength ("Coil Length", Float) = 1.0
        _CoilLengthScatter ("Coil Length Scatter", Float) = 0.2
        _NoiseStrength ("Noise Strength", Float) = 0.1
        _MeshStartX ("Mesh Start X (the edge coordinate)", Float) = 1.0

        [Enum(UnityEngine.Rendering.BlendMode)]       _SrcBlend ("SrcBlend", Int) = 5.0 // SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]       _DstBlend ("DstBlend", Int) = 10.0 // OneMinusSrcAlpha
        [Enum(Off, 0, On, 1)]                         _ZWrite ("ZWrite", Int) = 1.0 // On
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4.0 // LEqual
        [Enum(UnityEngine.Rendering.CullMode)]        _Cull ("Cull", Int) = 0.0 // Off
	}
	
	SubShader {
	
		Tags { "RenderType"="Opaque" }
		LOD 100

        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        ZTest [_ZTest]
        Cull [_Cull]

		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
            #include "Noise.cginc"

            fixed4 _Color;
            fixed4 _GlowColor;
            float _ArcFrequency;
            float _MaxArcDisplace;
            float _MaxCoilDisplace;
            float _CoilLength;
            float _CoilLengthScatter;
            float _NoiseStrength;
            float _MeshStartX;

			struct appdata {
				float4 vertex : POSITION;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				UNITY_FOG_COORDS(1)
			};
			
			v2f vert (appdata v) {
                float t = frac(_Time.y * _ArcFrequency);
                float pos = saturate((_MeshStartX - v.vertex.x) / (2.0 * _MeshStartX));
                float arcX = min(2 * pos, 2 - 2 * pos) - 1;
                float arc = 1 - arcX * arcX;

                float iteration = floor(_Time.y * _ArcFrequency);
                float nIteration = n11_a(iteration);

                float fixedDirInput = iteration * 2.5 + nIteration;
                float3 fixedDirOffset = arc * t * _MaxArcDisplace * float3(0, sin(fixedDirInput), cos(fixedDirInput));
                // fixedDirOffset = float3(0,0,0);

                float coilInput = pos * lerp(_CoilLength - _CoilLengthScatter, _CoilLength + _CoilLengthScatter, nIteration) + 6.28 * nIteration;
                float3 coilOffset = float3(0, sin(coilInput), cos(coilInput)) * smoothstep(0, 0.2, arc) * _MaxCoilDisplace;
                // coilOffset = float3(0,0,0);

                float3 noiseA = float3(0, 0.5 - n11_b(pos + iteration), 0.5 - n11_c(pos + iteration));
                float3 noiseB = float3(0, 0.5 - n11_b(pos + iteration + 1), 0.5 - n11_c(pos + iteration + 1));
                float3 noiseOffset = lerp(noiseA, noiseB, t) * 2 * _NoiseStrength * smoothstep(0, 0.2, arc);

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex + fixedDirOffset + coilOffset + noiseOffset);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 c = _Color;

				#if FOG_ON
					UNITY_CALC_FOG_FACTOR_RAW(length(_WorldSpaceCameraPos - i.worldPos.xyz));
					c.rgb = lerp(fixed3(0,0,0), c.rgb, saturate(unityFogFactor));
				#endif

				return c;
			}
			
			ENDCG
		}
	}
}
