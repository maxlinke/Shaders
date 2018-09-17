Shader "Custom/X_icetest"{

	//(start of an) attempt at recreating the ice-shader from deep rock galactic
	//works well on planes and cubes with fakedepth at -1
	//gotta do more experimenting (both with models and texture coordinate kinds (actual uv, vertex coordinates, ...))

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_TexDepth ("Fake Depth", Range(-1,1)) = 0
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		sampler2D _MainTex;
		fixed4 _Color;
		float _TexDepth;

		struct Input {
			float2 uv_MainTex;
			float3 tanViewDir;
		};

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float3x3 obj2tan = float3x3(
				v.tangent.xyz,
				cross(v.normal, v.tangent.xyz) * v.tangent.w,
				v.normal
			);
			o.tanViewDir = mul(obj2tan, ObjSpaceViewDir(v.vertex));
		}

		void surf (Input IN, inout SurfaceOutput o) {
			IN.tanViewDir = normalize(IN.tanViewDir);
			float2 parallaxUV = IN.uv_MainTex + (IN.tanViewDir.xy * _TexDepth);
			fixed4 c = tex2D (_MainTex, parallaxUV) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
