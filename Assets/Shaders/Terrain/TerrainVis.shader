Shader "Custom/Terrain/Terrain Visualization" {

	Properties {
		_LineColor ("Line Color", Color) = (0,0,0,1)
		_LineDist ("Line Distance", Float) = 1.0
		_LineOffset ("Line Offset", Range(0,1)) = 0.0
		_LineThreshA ("Line Threshold A", Range(0,1)) = 0.8
		_LineThreshB ("Line Threshold B", Range(0,1)) = 1.0

		_SteepOrHeight ("Display Steepness/Height", Range(0,1)) = 1.0
		
		_SteepColor ("Steepness Color", Color) = (1,1,1,1)
		[NoScaleOffset] _SteepTex ("Steepness Gradient Texture", 2D) = "white" {}

		_HeightColor ("Height Color", Color) = (1,1,1,1)
		[NoScaleOffset] _HeightTex ("Height Gradient Texture", 2D) = "white" {}
		_HeightZero ("Height Neutral Level", Float) = 0.0
		_HeightScale ("Height Scale", Float) = 100.0
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		fixed4 _LineColor;
		float _LineOffset;
		float _LineDist;
		float _LineThreshA;
		float _LineThreshB;

		float _SteepOrHeight;

		sampler2D _SteepTex;
		fixed4 _SteepColor;

		sampler2D _HeightTex;
		fixed4 _HeightColor;
		float _HeightZero;
		float _HeightScale;

		struct Input {
			float3 worldNormal;
			float3 worldPos;
			float steepness;
			float height;
			float linePos;
		};

		void vert(inout appdata_full v, out Input o){
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
			o.steepness = acos(dot(float3(0,1,0), o.worldNormal));
			o.steepness /= UNITY_PI;
			o.height = (o.worldPos.y - _HeightZero) / _HeightScale;
			o.height = (o.height + 1.0) / 2.0;
			o.linePos = (o.worldPos.y / _LineDist) + _LineOffset;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 steepCol = tex2D(_SteepTex, float2(IN.steepness, 0.5)) * _SteepColor;
			fixed4 heightCol = tex2D(_HeightTex, float2(IN.height, 0.5)) * _HeightColor;
			fixed4 tex = lerp(steepCol, heightCol, _SteepOrHeight);

			fixed linFrac = frac(IN.linePos);
			fixed linVal = saturate(1.0 - (2.0 * linFrac)) + saturate(-1.0 + (2.0 * linFrac));
			linVal = smoothstep(_LineThreshA, _LineThreshB, linVal);

			fixed4 c = lerp(tex, _LineColor, linVal * _LineColor.a);
			o.Albedo = c.rgb;
			o.Alpha = 1.0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

