Shader "Custom/Terrain/Terrain Visualization (Acos)" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture (RGB)", 2D) = "white" {}
		_Tiling ("Tiling", Float) = 1.0
		_Direction ("Direction", Vector) = (0, 1, 0, 0)
		_LineOffset ("Iso Line Offset", Range(0,1)) = 0.0
		_LinePower ("Iso Line Thinness", Float) = 1.0
		_SteepnessGradientTex ("Steepness Gradient Texture", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		fixed4 _Color;
		float3 _Direction;
		float _LineOffset;
		float _LinePower;
		sampler2D _SteepnessGradientTex;
		sampler2D _MainTex;
		float _Tiling;

		struct Input {
			float3 worldNormal;
			float3 worldPos;
			float lineVal;
			float3 coords;
			float steepCoord;
		};

		void vert(inout appdata_full v, out Input o){
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.lineVal = dot(o.worldPos, _Direction) - _LineOffset;
			o.coords = o.worldPos * _Tiling;
			float steepness = acos(dot(normalize(_Direction.xyz), normalize(o.worldNormal)));
			o.steepCoord = steepness / 3.141592654;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 steepCol = tex2D(_SteepnessGradientTex, float2(IN.steepCoord, 0.5));

			float up = pow(IN.lineVal - floor(IN.lineVal), _LinePower);
			float down = pow(ceil(IN.lineVal) - IN.lineVal, _LinePower); 

			half3 blendFactor = abs(IN.worldNormal);
			blendFactor /= dot(blendFactor, 1.0);

			fixed4 cx = tex2D(_MainTex, IN.coords.yz);
			fixed4 cy = tex2D(_MainTex, IN.coords.xz);
			fixed4 cz = tex2D(_MainTex, IN.coords.xy);
			fixed4 tex = cx * blendFactor.x + cy * blendFactor.y + cz * blendFactor.z;

			fixed4 c = tex * steepCol * _Color * saturate(1.0 - (up + down));
			o.Albedo = c.rgb;
			o.Alpha = 1.0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
