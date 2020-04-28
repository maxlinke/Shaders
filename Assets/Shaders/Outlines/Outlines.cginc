float _OutlineWidth;
float4 _Scale;

float4 CalculateOutlineClipPos (float4 vertex, float3 normal) {
    #if FIXED_OUTLINE_WIDTH
        float3 worldPos = mul(unity_ObjectToWorld, vertex).xyz;
        float camDist = length(_WorldSpaceCameraPos - worldPos);
        float multiplier = camDist / _ScreenParams.y;
        return UnityObjectToClipPos(vertex + (normal / _Scale * _OutlineWidth * multiplier));
    #else
        return UnityObjectToClipPos(vertex + (normal / _Scale * _OutlineWidth));
    #endif
}

struct simpleOutlineAppdata {
    float4 vertex : POSITION;
    float4 normal : NORMAL;
};

struct simpleOutlineV2F {
    float4 pos : SV_POSITION;
    UNITY_FOG_COORDS(1)
};

struct simpleOutlineFragOut {
    #if defined(OUTLINES_DEFERRED)
        float4 gBuffer0 : SV_Target0;
        float4 gBuffer1 : SV_Target1;
        float4 gBuffer2 : SV_Target2;
        float4 gBuffer3 : SV_Target3;
    #else
        float4  color : SV_TARGET;
    #endif
};

simpleOutlineV2F simpleOutlineVert (simpleOutlineAppdata v) {
    simpleOutlineV2F o;
    o.pos = CalculateOutlineClipPos(v.vertex, v.normal);
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}

simpleOutlineFragOut simpleOutlineFrag (simpleOutlineV2F i) {
    simpleOutlineFragOut o;
    fixed4 col = fixed4(0,0,0,1);
    #if defined(OUTLINES_DEFERRED)
        o.gBuffer0 = fixed4(0,0,0,1);
        o.gBuffer1 = fixed4(0,0,0,0);
        o.gBuffer2 = float4(0,0,0,1);
        o.gBuffer3 = col;
    #else
        UNITY_APPLY_FOG(i.fogCoord, col);
        o.color = col;
    #endif
    return o;
}