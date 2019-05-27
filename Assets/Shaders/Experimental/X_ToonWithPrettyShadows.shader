Shader "Custom/X_ToonWithPrettyShadows" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Iterations ("Edge Iterations", int) = 1
	}

	SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Toonish fullforwardshadows
		#pragma target 3.0

        fixed4 _Color;
        int _Iterations;
		sampler2D _MainTex;

        half4 LightingToonish (SurfaceOutput s, UnityGI gi) {
            float satNDotL = saturate(dot(gi.light.dir, s.Normal));
            float intensity = 1 - satNDotL;
            for(int i=0; i<_Iterations; i++){
                intensity *= intensity;
            }
            intensity = 1 - intensity;
            half4 c;
            c.rgb = s.Albedo * ((intensity * gi.light.color) + gi.indirect.diffuse);
            c.a = s.Alpha;
            return c;
        }

        inline void LightingToonish_GI (SurfaceOutput s, UnityGIInput data, inout UnityGI gi) {
            gi = UnityGlobalIllumination(data, 1.0, s.Normal);
        }

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
