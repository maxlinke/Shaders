struct appdata {
    float4 vertex : POSITION;
    float4 normal : NORMAL;
    float4 color : COLOR;   // r = frequency / 5, g = amplitude, b = noisiness, a = timing offset (for individual bunches)
    float2 uv : TEXCOORD0;  // x = "position" of vertex, y = extrusion width
};

struct v2f {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
};

fixed4 _Color;
fixed4 _GlowColor;
float _MaxThickness;
float _ArcFrequency;
float _ArcDrift;
float _EndDrift;
float _MinLat;
float _MaxLat;
float _MaxCoilDisplace;
float _CoilLength;
float _CoilLengthScatter;
float _NoiseStrength;

float n11 (float input) {
    return frac(frac((0.5 + input) * 2.45137) * (1.0 + input) * 3.71743);
}

float3 bezierPoint (float3 bStart, float3 bEnd, float3 bCtrl, float bT) {
    float bTInv = 1.0 - bT;
    return bCtrl + (bTInv * bTInv * (bStart - bCtrl)) + (bT * bT * (bEnd - bCtrl));
}

float3 bezierDerivative (float3 bStart, float3 bEnd, float3 bCtrl, float bT) {
    return (2.0 * (1.0 - bT) * (bCtrl - bStart)) + (2 * bT * (bEnd - bCtrl));
}

float3 randomLatLongPoint (float seed, float minLat, float maxLat) {
    float long = n11(seed) * 6.28;
    float lat = lerp(minLat, maxLat, n11(seed + 1));
    float cosLat = cos(lat * 1.57);
    return float3(sin(long) * cosLat, cos(long) * cosLat, lat);
}

float3 calculateVertexPosition (appdata v, float normalOffsetMultiplier) {
    float time = (_Time.y + v.color.a + floor(100 * n11(v.color.a))) * _ArcFrequency;
    float t = frac(time);
    float i = floor(time);
    float n11i = n11(i);
    // quadratic bezier curve
    float bT = v.uv.x;      // uncouples it from the mesh itself. might revert if i need the uvs for a different purpose
    float bTArc = sin(bT * 3.14);
    float3 bStart = float3(0,0,0);
    float3 bcoA = randomLatLongPoint(i+2, -1, 1);
    float3 bcoB = -bcoA;
    float3 bcoC = 0.5 * randomLatLongPoint(i+5, -1, 1);
    float3 bCtrl = float3(0.0, 0.0, 0.5) + _ArcDrift * bezierPoint(bcoA, bcoB, bcoC, t);
    float3 bEnd = float3(0.0, 0.0, 0.5) + 0.5 * randomLatLongPoint(i+1, _MinLat, _MaxLat);
    float3 bPos = bezierPoint(bStart, bEnd, bCtrl, bT);
    // rotation matrix for points
    float3 bFwd = bezierDerivative(bStart, bEnd, bCtrl, bT);
    float3 bA = normalize(cross(bFwd, bezierDerivative(bStart, bEnd, bCtrl, bT - 0.01)));
    float3 bB = normalize(cross(bFwd, bA));
    float3x3 rot = transpose(float3x3(bA, bB, bFwd));
    // coiling for a more interesting curve
    float coilT = frac(time * v.color.r * 5.0);
    float coilI = floor(time * v.color.r * 5.0);
    float coilAmp = v.color.g;
    float coilRandom = n11(coilI);
    float coilInput = bT * lerp(_CoilLength - _CoilLengthScatter, _CoilLength + _CoilLengthScatter, coilRandom) + 27.1256 * coilRandom;
    float3 coilOffset = float3(sin(coilInput + t), cos(coilInput + t), 0) * bTArc * _MaxCoilDisplace * coilAmp;
    // noise
    float noiseStrength = _NoiseStrength * v.color.b;
    float3 noiseA = float3(0.5 - n11(bT + i), 0.5 - n11(bT + i), 0);
    float3 noiseB = float3(0.5 - n11(bT + i + 1), 0.5 - n11(bT + i + 1), 0);
    float3 noiseOffset = lerp(noiseA, noiseB, t) * 2 * smoothstep(0, 0.2, bTArc) * noiseStrength;
    // do the stuff here...
    float3 finalVertex = bPos + mul(rot, coilOffset + noiseOffset) + _MaxThickness * normalOffsetMultiplier * v.uv.y * mul(rot, v.normal.xyz);
    return finalVertex;
}