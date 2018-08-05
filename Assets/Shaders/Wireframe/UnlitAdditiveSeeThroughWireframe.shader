Shader "Custom/Wireframe/UnlitAdditiveSeeThroughWireframe"{

	Properties{
		_Color ("Color", Color) = (0,0,0,1)
		_WireColor ("Wireframe Color", Color) = (1,1,1,1)
		_WireWidth ("Wire Width", Range(0,10)) = 1.0
		_WireSmoothing ("Wire Smoothing", Range(0,10)) = 0.0
	}

	SubShader{

		Tags { "Queue" = "Transparent" }
		LOD 100

		ZWrite Off
		Blend One One
		Cull Off

		Pass{

			CGPROGRAM
			#pragma vertex wireVert
			#pragma fragment wireFrag
			#pragma geometry wireGeom
			#pragma multi_compile_fog

			#define WIRES_ADDITIVE

			#include "UnityCG.cginc"
			#include "Wireframes.cginc"

			ENDCG
		}
	}
}
