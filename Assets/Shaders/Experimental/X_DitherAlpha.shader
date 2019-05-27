Shader "Custom/Experimental/X_DitherAlpha" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Alpha ("Alpha", Range(0, 1)) = 1
	}

	SubShader {

		Tags { "RenderType"="Opaque" "Queue"="AlphaTest" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert
        #include "../ScreenSpaceUtils.cginc"
		
        fixed4 _Color;
        float _Alpha;
        sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
            float4 screenPos;
		};

		void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            float2 pixelCoords = ScreenPosToPixelCoords(XYScreenPos(IN.screenPos));
            float dt = DitherThresholdAtPixelPos(pixelCoords);

            fixed texAlpha = c.a * _Alpha;
            clip(step(1 - texAlpha, dt) - 0.5);

            o.Albedo = c.rgb;
            o.Alpha = 1;
		}
		ENDCG

        Pass {

            Name "DitheredShadows"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "../ScreenSpaceUtils.cginc"

            fixed4 _Color;
            float _Alpha;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2f {
                float2 uv  : TEXCOORD0;
            };

            v2f vert (appdata v, out float4 outpos : SV_POSITION) {
                outpos = UnityApplyLinearShadowBias(UnityClipSpaceShadowCasterPos(v.vertex, v.normal));
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_TARGET {
                fixed4 c = _Color * tex2D(_MainTex, i.uv);
                float2 pixelCoords = ScreenPosToPixelCoords(XYScreenPos(screenPos));
                float dt = DitherThresholdAtPixelPos(pixelCoords);

                fixed texAlpha = c.a * _Alpha;
                clip(step(1 - texAlpha, dt) - 0.5);
                return 0;
            }

            ENDCG

        }

	}
	// FallBack "Diffuse"
}
