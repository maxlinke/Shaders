Shader "Custom/Glowing/Worldpos"{
	
	Properties{
		_MainTex ("Texture", 2D) = "white" {}
	}
	
	SubShader{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }

		Pass{
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldpos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				//return fixed4(abs(i.worldpos.xyz) % 1, 1);
				/*
				fixed4 c;
				c.r = i.worldpos.x - (int)i.worldpos.x +1;
				c.g = i.worldpos.y - (int)i.worldpos.y +1;
				c.b = i.worldpos.z = (int)i.worldpos.z +1;
				return fixed4(c.rgb, 1);
				*/
				return fixed4(i.worldpos.xyz - floor(i.worldpos.xyz), 1);
				//return tex2D(_MainTex, i.worldpos);
			}
			ENDCG
		}
	}

	Fallback "VertexLit"
}
