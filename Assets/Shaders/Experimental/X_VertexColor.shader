Shader "Custom/Experimental/X_VertexColor" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		fixed4 _Color;

		struct Input {
			fixed4 vertCol : COLOR;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			
			fixed4 c = _Color * IN.vertCol;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
