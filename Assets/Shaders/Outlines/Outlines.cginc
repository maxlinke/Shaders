#include "UnityCG.cginc"

float _OutlineWidth;
float4 _Scale;

#if defined (SLICE)
float4 _SlicePos;
float4 _SliceNormal;
#endif

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
    #if defined (SLICE)
    float slice : TEXCOORD2;
    #endif
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
    #if defined (SLICE)
        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.slice = dot(worldPos - _SlicePos.xyz, _SliceNormal.xyz);
    #endif
    return o;
}

simpleOutlineFragOut simpleOutlineFrag (simpleOutlineV2F i) {
    #if defined (SLICE)
        clip(i.slice);
    #endif
    simpleOutlineFragOut o;
    fixed4 col = fixed4(0,0,0,1);
    #if defined(OUTLINES_DEFERRED)
        o.gBuffer0 = fixed4(0,0,0,1);
        o.gBuffer1 = fixed4(0,0,0,0);
        o.gBuffer2 = float4(0.5, 0.5, 1.0 ,1);
        col = fixed4(col.rgb, 0.0);
        #ifdef UNITY_HDR_ON             // this is the weirdest shit...
        o.gBuffer3 = col;
        #else
        o.gBuffer3 = fixed4(1,1,1,0) - col;
        #endif
    #else
        UNITY_APPLY_FOG(i.fogCoord, col);
        o.color = col;
    #endif
    return o;
}