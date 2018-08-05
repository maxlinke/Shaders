Shader "Custom/Wireframe/UnlitWireframe"{

	Properties{
		_Color ("Color", Color) = (1,1,1,1)
		_WireColor ("Wireframe Color", Color) = (0,0,0,1)
		_WireWidth ("Wire Width", Range(0,10)) = 1.0
		_WireSmoothing ("Wire Smoothing", Range(0,10)) = 0.0
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
			#include "Wireframes.cginc"

			ENDCG
		}
	}
}
