Shader "Custom/X_icetest"{

	//(start of an) attempt at recreating the ice-shader from deep rock galactic
	//works well on planes and cubes with fakedepth at -1
	//gotta do more experimenting (both with models and texture coordinate kinds (actual uv, vertex coordinates, ...))

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_HeightTex ("Heightmap", 2D) = "grey" {}
		_HeightTexScale ("Heightmap Scale", Range(0,1)) = 0.2
		_HeightOffset ("Height Offset", Range(-1,1)) = 0
		_DistortionLevel ("Distortion Level (Surface or Inside)", Range(0,1)) = 0

		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_Hardness ("Specular Hardness", Range(0,1)) = 0.5
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CustomBlinnPhong vertex:vert
		#include "CustomLighting.cginc"


		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _HeightTex;
		float _HeightTexScale;
		float _HeightOffset;
		float _DistortionLevel;

		float _Hardness;

		struct Input {
			float2 uv_MainTex;
			float2 uv_HeightTex;
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

		void surf (Input IN, inout CustomSurfaceOutput o) {
			IN.tanViewDir = normalize(IN.tanViewDir);
			float2 heightTexCoord = IN.uv_HeightTex;
			heightTexCoord += _DistortionLevel * IN.tanViewDir * _HeightOffset;
			fixed heightTex = tex2D(_HeightTex, heightTexCoord).g;
			float height = _HeightOffset + ((heightTex * 2.0 - 1.0) * _HeightTexScale);
			float2 parallaxUV = IN.uv_MainTex + (IN.tanViewDir.xy * height);

			fixed4 c = tex2D (_MainTex, parallaxUV) * _Color;
			fixed4 s = _SpecColor;

			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.SpecCol = s.rgb;
			o.Hardness = _Hardness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
