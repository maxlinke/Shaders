Shader "Custom/Experimental/Stencil/X_StencilPortal" {

	Properties {	}

	SubShader {

		Tags { "RenderType" = "Opaque" "Queue" = "Geometry+1" }
		LOD 100

		Pass {

			ZTest LEqual
			ZWrite Off
			ColorMask 0

			Stencil{
				Ref 37
				Comp Always
				Pass Replace
			}

		}
	}
}
