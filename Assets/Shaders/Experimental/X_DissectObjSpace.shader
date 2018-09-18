Shader "Custom/Experimental/X_DissectObjSpace" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_InsideColor ("Inside Color", Color) = (1,0,0,1)
		_Offset ("Offset Vector", Vector) = (0,0,0,0)
		_Direction ("Direction Vector", Vector) = (1,0,0,0)
	}

	SubShader {

		Cull Off

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert addshadow
		#pragma target 3.0

		half4 _Offset;
		half4 _Direction;

		fixed4 _Color;
		sampler2D _MainTex;
		fixed4 _InsideColor;

		struct Input {
			float2 uv_MainTex;
			float slice;
			fixed face : VFACE;
		};

		void vert(inout appdata_full v, out Input o){
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.slice = dot(v.vertex.xyz - _Offset.xyz, _Direction.xyz);
		}

		void surf (Input IN, inout SurfaceOutput o) {
			clip(IN.slice);
			fixed4 tex = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed faceStep = step(0.5, IN.face);
			fixed4 c = faceStep * tex;
			fixed4 e = (1 - faceStep) * _InsideColor;
			o.Albedo = c.rgb;
			o.Emission = e.rgb;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
