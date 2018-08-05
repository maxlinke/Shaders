Shader "Custom/Effects/Pixelator"{

	//https://forum.unity.com/threads/making-a-local-pixelation-image-effect-shader.183210/#post-1252552

	//i know the viewdot and tint stuff probably wont be used and is detrimental to performance
	//but we're talking about grabpasses here. so performance isn't really our main concern, eh?. 

	Properties{
		_TintCol ("Tint Color", Color) = (1, 1, 1, 1)
		_RimTint ("Rim Tint Color", Color) = (1, 1, 1, 1)
		_AbsolutePixelSize ("Pixel Size (Absolute)", Range(1, 20)) = 5
		_RelativePixelSize ("Pixel Size (Relative)", Range(0, 1)) = 0.01
		_AbsOrRel ("Absolute or Relative", Range(0, 1)) = 1
	}

	SubShader{

		Tags { "Queue" = "Transparent+1" }

		GrabPass {
			"_BackgroundTexture"
		}

		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			float _AbsOrRel;
			float _AbsolutePixelSize;
			float _RelativePixelSize;
			fixed4 _TintCol;
			fixed4 _RimTint;
			sampler2D _BackgroundTexture;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 grabPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 viewDir : TEXCOORD3;
				UNITY_FOG_COORDS(4)
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.pos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);
				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 relPixelSize = _RelativePixelSize * float2((_ScreenParams.y / _ScreenParams.x), 1.0);	//same RELATIVE "PIXEL" size (same aspect ratio, same image)
				float2 absPixelSize = _AbsolutePixelSize / _ScreenParams.xy;									//same ACTUAL PIXEL size (image varies with resolution)
				float2 actualPixelSize = lerp(absPixelSize, relPixelSize, _AbsOrRel);
				float2 steppedUV = i.grabPos.xy / i.grabPos.w;
				steppedUV /= actualPixelSize;
				steppedUV = round(steppedUV);
				steppedUV *= actualPixelSize;
				float viewDot = dot(i.worldNormal, i.viewDir);
				fixed4 tint = lerp(_RimTint, _TintCol, abs(viewDot));
				fixed4 col = tex2D(_BackgroundTexture, steppedUV) * tint;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
