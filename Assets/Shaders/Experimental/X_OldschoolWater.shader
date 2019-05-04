Shader "Custom/Experimental/X_OldschoolWater" {
	
    Properties {
		_Color ("Color", Color) = (1,1,1,1)
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
        [NoScaleOffset] _FlowTex ("Flow Texture", 2D) = "grey" {}
        _MainTiling ("Main Tiling", float) = 1
        _FlowTiling ("Flow Tiling", float) = 1
        _WaveStrength ("Wave Strength", float) = 1
        _FlowSpeed ("Flow Speed", float) = 1
        _TexDistortion ("Texture Distortion", float) = 1
	}
	
    SubShader {

		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert addshadow

		#pragma target 3.0

        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _FlowTex;
        float _MainTiling;
        float _FlowTiling;
        float _WaveStrength;
        float _FlowSpeed;
        float _TexDistortion;

		struct Input {
			// float2 uv_MainTex;
            float4 mainCoords;
            float4 flowCoords;
		};

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.mainCoords = v.vertex / _MainTiling;
            o.flowCoords = v.vertex / _FlowTiling;
            fixed4 flowSample = tex2Dlod(_FlowTex, float4(o.flowCoords.xz, 0, 1)) * 6.28;
            float scaledTime = _Time.y * _FlowSpeed;
            float yOff = sin(scaledTime + (flowSample.r + flowSample.g));
            v.vertex += float4(0, _WaveStrength * yOff, 0, 0);
        }

		void surf (Input IN, inout SurfaceOutput o) {
            fixed4 flow = tex2D(_FlowTex, IN.flowCoords.xz) * 6.28;
            float scaledTime = _Time.y * _FlowSpeed;
            float2 texOffset = float2(sin(scaledTime + flow.r), sin(scaledTime + flow.g)) * _TexDistortion;
			fixed4 c = tex2D (_MainTex, IN.mainCoords.xz + texOffset) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
