//https://en.wikipedia.org/wiki/Ordered_dithering
static const float ditherThresholds [16] = {
     0.0000, 0.5000, 0.1250, 0.6250, 
     0.7500, 0.2500, 0.8750, 0.3750, 
     0.1875, 0.6875, 0.0625, 0.5625, 
     0.9375, 0.4375, 0.8125, 0.3125
};

float2 XYScreenPos (float4 entireScreenPosition) {
    return entireScreenPosition.xy / max(entireScreenPosition.w, 0.001);
}

float2 ScreenPosToPixelCoords (float2 screenPosition) {
    return screenPosition * _ScreenParams.xy;
}

float DitherThresholdAtPixelPos (float2 pixelPosition) {
    float2 matrixCoords = frac(pixelPosition / 4) * 4;
    int arrayIndex = (4 * floor(matrixCoords.y)) + floor(matrixCoords.x);
    return ditherThresholds[arrayIndex];
}