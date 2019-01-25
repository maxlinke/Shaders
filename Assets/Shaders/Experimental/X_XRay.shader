Shader "Custom/Experimental/X_XRay" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_XRayColor ("X-Ray Color", Color) = (1,0.6,0.2,1)
	}

	SubShader {

		Tags { "Queue"="AlphaTest+1" }

		CGPROGRAM

		#pragma surface surf Lambert

		fixed4 _Color;
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG

		Pass {

			ZWrite Off
			ZTest LEqual
			ColorMask 0

			Stencil {
				Ref 59
				Comp Always
				Pass Replace
			}

		}

		Pass {

			ZWrite Off
			ZTest Greater

			Stencil {
				Ref 59
				Comp NotEqual
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _XRayColor;

			struct v2f {
				float4 pos : SV_POSITION;
			};

			v2f vert (appdata_base v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
	
			fixed4 frag (v2f i) : SV_TARGET {
				return _XRayColor;
			}
	
			ENDCG

		}

	}

	FallBack "Diffuse"
}
