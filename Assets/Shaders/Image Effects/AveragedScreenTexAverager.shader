Shader "Custom/Image Effects/Averaged Screen Tex Averager"{

	Properties{
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
		_BlendAmount ("Blend Amount", Range(0, 1)) = 0.5
        _FlowTex ("(Periodic) Flow Map", 2D) = "grey" {}
        _FlowSpeed ("(Periodic) Flow Speed", float) = 1
        _FlowStrength ("(Periodic) Flow Strength", Range(0, 1)) = 0.01
        _FixedFlow ("Fixed Flow", Vector) = (0, 1, 0, 0)
        _BlurAmount ("Blur Amount", Range(0, 1)) = 0.01
	}

	SubShader{

		Cull Off
		ZWrite Off
		ZTest Always

		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _FlowTex;
            float4 _FlowTex_ST;
            float _FlowSpeed;
            float _FlowStrength;
            float4 _FixedFlow;
            float _BlurAmount;

            sampler2D _AveragedScreenTex;

            float _BlendAmount;

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
                float2 flowUV : TEXCOORD1;
			};

			v2f vert (appdata v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.flowUV = TRANSFORM_TEX(v.uv, _FlowTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target{
				fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 flow = tex2D(_FlowTex, i.flowUV) * 6.28;     //the flowuv seems to be irrelevant... shame...
                float flowTime = _Time.y * _FlowSpeed;
                float2 constantFlowOffset = float2(_FixedFlow.x, _FixedFlow.y);
				float2 periodicFlowOffset = float2(sin(flowTime + flow.r), sin(flowTime + flow.g)) * _FlowStrength;
                float2 blurUVOffset = constantFlowOffset + periodicFlowOffset;
                float2 blurTexUVCoords = i.uv + blurUVOffset;
                fixed4 blurTexSample = tex2D(_AveragedScreenTex, blurTexUVCoords);
                fixed4 blur = blurTexSample
                    + tex2D(_AveragedScreenTex, blurTexUVCoords + float2(_BlurAmount, 0))
                    + tex2D(_AveragedScreenTex, blurTexUVCoords + float2(-_BlurAmount, 0))
                    + tex2D(_AveragedScreenTex, blurTexUVCoords + float2(0, _BlurAmount))
                    + tex2D(_AveragedScreenTex, blurTexUVCoords + float2(0, -_BlurAmount));
                blur /= 5;
				return lerp(tex, blur, _BlendAmount);
			}
			ENDCG
		}
	}
}
