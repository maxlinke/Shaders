//#ifndef WIRES_OPAQUE
//	#ifndef WIRES_ADDITIVE
//		#define WIRES_OPAQUE
//	#endif
//#endif

#if !defined(WIRES_OPAQUE) && !defined(WIRES_ADDITIVE)
	#define WIRES_OPAQUE
#endif

fixed4 _Color;
fixed4 _WireColor;
float _WireWidth;
float _WireSmoothing;

struct appdata{
	float4 vertex : POSITION;
};

struct v2f{
	float4 pos : SV_POSITION;
	UNITY_FOG_COORDS(0)
};

struct g2f{
	v2f data;
	float3 baryCoords : TEXCOORD9;
};
			
v2f wireVert (appdata v){
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}

[maxvertexcount(3)]
void wireGeom(triangle v2f i[3], inout TriangleStream<g2f> stream){
	g2f g0, g1, g2;

	g0.data = i[0];
	g1.data = i[1];
	g2.data = i[2];

	g0.baryCoords = float3(1,0,0);
	g1.baryCoords = float3(0,1,0);
	g2.baryCoords = float3(0,0,1);

	stream.Append(g0);
	stream.Append(g1);
	stream.Append(g2);
}
			
fixed4 wireFrag (g2f i) : SV_Target{
	float3 bary = i.baryCoords;
	float3 deltas = fwidth(bary);
	float3 smoothing = deltas * _WireSmoothing;
	float3 width = deltas * 0.5 * _WireWidth;
	bary = smoothstep(width, width + smoothing, bary);
	float minBary = min(bary.x, min(bary.y, bary.z));
	fixed4 col = lerp(_WireColor, _Color, minBary);
	#if defined (WIRES_OPAQUE)
		UNITY_APPLY_FOG(i.data.fogCoord, col);
	#endif
	#if defined (WIRES_ADDITIVE)
		UNITY_APPLY_FOG_COLOR(i.data.fogCoord, col, fixed4(0,0,0,1));
	#endif
	return col;
}