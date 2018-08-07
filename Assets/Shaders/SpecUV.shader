Shader "Custom/SpecUV" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_SpecTex ("Specular Texture", 2D) = "white" {}
		_Hardness ("Specular Hardness", Range(0,1)) = 0.5
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Custom

		sampler2D _MainTex;
		sampler2D _SpecTex;
		fixed4 _Color;
//		fixed4 _SpecColor;		<- already declared in UnityLightingCommon.cginc
		float _Hardness;

		struct Input {
			float2 uv_MainTex;
			float2 uv_SpecTex;
		};

		struct CustomSurfaceOutput{
			fixed3 Albedo;
			fixed3 SpecCol;
			fixed3 Normal;
			fixed3 Emission;
			fixed Hardness;
			fixed Alpha;
		};

		inline half4 LightingCustom (CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
			lightDir = normalize(lightDir);
			viewDir = normalize(viewDir);
			s.Normal = normalize(s.Normal);

			half diff = saturate(dot(lightDir, s.Normal));

			half3 halfVec = normalize(lightDir + viewDir);
			half spec = pow(saturate(dot(s.Normal, halfVec)), s.Hardness * 128.0);

			half4 c;
			c.rgb = ((diff * s.Albedo) + (spec * s.SpecCol)) * atten * _LightColor0.rgb;
			c.a = s.Alpha;
			return c;
		}

		void surf (Input IN, inout CustomSurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 s = tex2D (_SpecTex, IN.uv_SpecTex) * _SpecColor;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.SpecCol = s.rgb;
			o.Hardness = _Hardness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
