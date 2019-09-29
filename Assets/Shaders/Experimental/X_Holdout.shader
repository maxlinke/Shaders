Shader "Custom/Experimental/X_Holdout" {

	Properties { }

	SubShader {

		Tags { "RenderType"="Opaque" "Queue" = "Background-1" } //bg+1 to "clear to skybox"
		LOD 100

		Pass {

			ColorMask 0
            ZTest Always
            ZWrite On

		}
	}
}
