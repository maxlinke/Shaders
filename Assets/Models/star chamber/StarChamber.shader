Shader "Custom/StarChamber" {

	Properties {
		[NoScaleOffset] _ControlTex ("Control Texture", 2D) = "white" {}
		_WallTex ("Wall Texture", 2D) = "white" {}
//		_FloorTex ("Floor Texture", 2D) = "white" {}
		_GridColor ("Grid Color", Color) = (1,1,1,1)
		[NoScaleOffset] _GridTex ("Grid Texture", 2D) = "black" {}
		_GridTiling ("Grid Tiling", Float) = 1.0
		_GridLayers ("Grid Layers", int) = 4
		_GridDistance ("Distance between layers", Float) = -1.0
		_FadeDistanceScale ("Fade distance scale", Float) = 1.0
		_FadeDistanceOffset ("Fade distance offset", Float) = 0.0
		_StarTex ("Star Texture", CUBE) = "black" {}
	}

	SubShader {

		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		#pragma surface surf Standard vertex:vert

		#pragma target 3.0

		sampler2D _ControlTex;
		sampler2D _WallTex;
//		sampler2D _FloorTex;
		fixed4 _GridColor;
		sampler2D _GridTex;
		samplerCUBE _StarTex;
		float _GridTiling;
		int _GridLayers;
		float _GridDistance;
		float _FadeDistanceScale;
		float _FadeDistanceOffset;

		struct Input {
			float2 uv_ControlTex;
			float2 uv_WallTex;
//			float2 uv_FloorTex;
			float3 viewDir;
			float4 tanViewDirAndDist;
		};

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float3x3 obj2tan = float3x3(
				v.tangent.xyz,
				cross(v.normal, v.tangent.xyz) * v.tangent.w,
				v.normal);
			fixed3 tanViewDir = mul(obj2tan, ObjSpaceViewDir(v.vertex));
			float dist = length(WorldSpaceViewDir(v.vertex));
//			dist = saturate(_FadeDistanceOffset - (dist * _FadeDistanceScale));
//			float dist = distance(_WorldSpaceCameraPos, mul(_Object2World, v.vertex).xyz);
			dist *= _FadeDistanceScale;
			dist -= _FadeDistanceOffset;
			dist = saturate(dist);
			o.tanViewDirAndDist = float4(0,0,0,0);
			o.tanViewDirAndDist.xyz = tanViewDir;
			o.tanViewDirAndDist.w = dist;		//this requires a high-ish poly mesh because, well, i interpolate the distance instead of calculating it in the fragment shader, which would be a lot better...
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float3 tanViewDir = normalize(IN.tanViewDirAndDist.xyz);
			fixed4 control = tex2D (_ControlTex, IN.uv_ControlTex);
//			fixed4 concrete = (control.r * tex2D(_WallTex, IN.uv_WallTex)) + (control.g * tex2D(_FloorTex, IN.uv_FloorTex));
			fixed4 concrete = (control.r + control.g) * tex2D(_WallTex, IN.uv_WallTex);
			fixed4 stars = texCUBE(_StarTex, IN.viewDir);

			float2 gridUV = IN.uv_ControlTex * _GridTiling;
			fixed4 grid = tex2D(_GridTex, gridUV);
			for(int i=1; i<_GridLayers; i++){
				float2 newUV = gridUV + (i * tanViewDir.xy * _GridDistance);
				grid += tex2D(_GridTex, newUV) * (1.0 - (float)i / _GridLayers);
			}
			grid *= _GridColor;
			grid *= 1.0 - IN.tanViewDirAndDist.w;
//			grid *= IN.tanViewDirAndDist.w;

			o.Albedo = concrete.rgb * control.a;
			o.Emission = (grid + stars) * (1.0 - control.a);
			o.Occlusion = control.b;
			o.Alpha = concrete.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
