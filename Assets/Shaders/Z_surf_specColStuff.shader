//this is highly confusing. i just want a shader that renormalizes the normal and allows me a texture for specular color. and that isn't the standard shader!!!

Shader "Custom/Z_surf_specColStuff" {

	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_SpecMap ("Specular Color", 2D) = "white" {}
		_NormMap ("Normal Map", 2D) = "bump" {}
		_Hardness ("Specular Hardness", Range(0.0, 1.0)) = 0.5
		_Glossiness ("Glossiness", Range(0.0, 1.0)) = 1.0
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

//		inline half4 LightingColoredSpecular (MySurfaceOutput s, half3 lightDir, half3 viewDir, half atten){
//			half3 halfVector = normalize (lightDir + viewDir);
//			float spec = pow(saturate(dot(halfVector, s.Normal)), s.Specular * 100); 
//			half diff = saturate(dot (s.Normal, lightDir));
//			half4 c;
//			c.rgb = diff * atten * _LightColor0.rgb * s.Albedo;
////			c.rgb = (s.Albedo * _LightColor0.rgb * diff) * (atten * 2);
//			c.rgb += spec * atten * _LightColor0.rgb * s.GlossColor;
//			c.a = s.Alpha;
//			return c;
//		}
		
		// NOTE: some intricacy in shader compiler on some GLES2.0 platforms (iOS) needs 'viewDir' & 'h'
		// to be mediump instead of lowp, otherwise specular highlight becomes too bright.
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
		
    		return c * UNITY_PI;	//<- wtf why
		}

		inline half4 LightingColoredSpecular_Deferred (MySurfaceOutput s, half3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
		{
    		UnityStandardData data;
    		data.diffuseColor   = s.Albedo;
    		data.occlusion      = 1;
    		// PI factor come from StandardBDRF (UnityStandardBRDF.cginc:351 for explanation)
    		data.specularColor  = s.GlossColor.rgb * s.Gloss;
    		data.smoothness     = s.Specular;
    		data.normalWorld    = s.Normal;
		
    		UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);
		
    		half4 emission = half4(s.Emission, 1);
		
    		#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
        		emission.rgb += s.Albedo * gi.indirect.diffuse;
    		#endif
		
    		return emission * UNITY_PI;
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
    		return c * UNITY_PI;
		}

		struct Input {
			float2 uv_MainTex;
			float2 uv_SpecMap;
			float2 uv_NormTex;
		};

		sampler2D _MainTex;
		sampler2D _SpecMap;
		sampler2D _NormTex;
		float _Hardness;
		float _Glossiness;

		void surf (Input IN, inout MySurfaceOutput o){
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * 0.3;
			half4 spec = tex2D (_SpecMap, IN.uv_SpecMap);
			o.Normal = UnpackNormal(tex2D(_NormTex, IN.uv_NormTex));
			o.GlossColor = spec.rgb;
			o.Specular = _Hardness;
			o.Gloss = _Glossiness;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
 