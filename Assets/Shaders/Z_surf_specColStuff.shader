//this is highly confusing. i just want a shader that renormalizes the normal and allows me a texture for specular color. and that isn't the standard shader!!!

Shader "Custom/Z_surf_specColStuff" {

	Properties {
		_Color ("Color", Color) = (1, 1, 1, 1)
		_SpecularColor ("Specular Color Multiplier", Color) = (1, 1, 1, 1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_SpecMap ("Specular Color", 2D) = "white" {}
		_Hardness ("Specular Hardness", Range(0.0, 1.0)) = 0.5
		_Glossiness ("Glossiness", Range(0.0, 2.0)) = 1.0
	}

	SubShader {

		Tags { "RenderType" = "Opaque" }

		CGPROGRAM
		#pragma surface surf ColoredSpecular

		struct MySurfaceOutput {
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Specular;
			half Gloss;
			half3 GlossColor;
			half Alpha;
		};

		inline fixed4 UnityBlinnPhongLight (MySurfaceOutput s, half3 viewDir, UnityLight light)
		{
			half3 normedNormal = normalize(s.Normal);
    		fixed diff = saturate( dot (normedNormal, light.dir));
		    half3 h = normalize (light.dir + viewDir);
    		float nh = saturate( dot (normedNormal, h));
    		float spec = pow (nh, s.Specular*128.0) * s.Gloss;

    		fixed4 c;
    		c.rgb = s.Albedo * light.color * diff + light.color * s.GlossColor.rgb * spec;
    		c.a = s.Alpha;
		
    		return c;
		}

		inline fixed4 LightingColoredSpecular (MySurfaceOutput s, half3 viewDir, UnityGI gi)
		{
    		fixed4 c;
    		c = UnityBlinnPhongLight (s, viewDir, gi.light);
		
    		#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
        		c.rgb += s.Albedo * gi.indirect.diffuse;
    		#endif
		
    		return c;
		}

		inline half4 LightingColoredSpecular_Deferred (MySurfaceOutput s, half3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
		{
    		UnityStandardData data;
    		data.diffuseColor   = s.Albedo;
    		data.occlusion      = 1;
    		// PI factor come from StandardBDRF (UnityStandardBRDF.cginc:351 for explanation)
    		data.specularColor  = s.GlossColor.rgb * s.Gloss * (1.0 / UNITY_PI);	//<- why pi? idk...
    		data.smoothness     = s.Specular;
    		data.normalWorld    = s.Normal;
		
    		UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);
		
    		half4 emission = half4(s.Emission, 1);
		
    		#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
        		emission.rgb += s.Albedo * gi.indirect.diffuse;
    		#endif
		
    		return emission;
		}
		
		inline void LightingColoredSpecular_GI (
    		MySurfaceOutput s,
    		UnityGIInput data,
    		inout UnityGI gi)
		{
    		gi = UnityGlobalIllumination (data, 1.0, s.Normal);
		}

		inline void ColoredSpecular_GI (
    		MySurfaceOutput s,
    		UnityGIInput data,
    		inout UnityGI gi)
		{
    		gi = UnityGlobalIllumination (data, 1.0, s.Normal);
		}
		
		inline fixed4 LightingColoredSpecular_PrePass (MySurfaceOutput s, half4 light)
		{
    		fixed spec = light.a * s.Gloss;
		
    		fixed4 c;
    		c.rgb = (s.Albedo * light.rgb + light.rgb * s.GlossColor.rgb * spec);
    		c.a = s.Alpha;
    		return c;
		}

		struct Input {
			float2 uv_MainTex;
			float2 uv_SpecMap;
		};

		fixed4 _Color;
		fixed4 _SpecularColor;
		sampler2D _MainTex;
		sampler2D _SpecMap;
		float _Hardness;
		float _Glossiness;

		void surf (Input IN, inout MySurfaceOutput o){
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * _Color;
			half4 spec = tex2D (_SpecMap, IN.uv_SpecMap);
//			o.Normal = UnpackNormal(tex2D(_NormTex, IN.uv_NormTex));
			o.GlossColor = spec.rgb * _SpecularColor;
			o.Specular = _Hardness;
			o.Gloss = _Glossiness;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
 