Shader "Custom/Experimental/X_XRay" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_XRayColor ("X-Ray Color", Color) = (1,0.6,0.2,1)
		_StencilID ("Stencil ID", int) = 0
	}

	SubShader {

		Tags { "RenderType"="Opaque" "Queue"="Geometry" }

		Stencil {
			Ref [_StencilID]
			Comp Always
			Pass Replace
		}

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

			Tags { "Queue"="Transparent" }

			ZWrite Off
			ZTest Greater

			Stencil {
				Ref [_StencilID]
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
