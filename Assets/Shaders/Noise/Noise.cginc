// individual hash functions

float n11_a (float input) {
    // return frac(frac(input * 24.5137) * input * 37.1743);
    return frac(frac((0.5 + input) * 24.5137) * (1.0 + input) * 37.1743);
    // return frac(frac(input * 2234.57) * input * 357.13);
    // return 0.0;
}

float n11_b (float input) {
    // return frac(frac(input * 37.6391) * input * 29.1279);
    return frac(frac((2.0 + input) * 37.6391) * (0.5 + input) * 29.1279);
    // return frac(frac(input * 3187.91) * input * 298.79);
    // return 0.0;
}

float n11_c (float input) {
    // return frac(frac(input * 35.4863) * input * 31.7107);
    return frac(frac((1.0 + input) * 35.4863) * (2.0 + input) * 31.7107);
    // return frac(frac(input * 3521.43) * input * 313.77);
    // return 0.0;
}

float n11_d (float input) {
    // return frac(frac(input * 20.9121) * input * 43.0521);
    return frac(frac((0.5 + input) * 20.9121) * (2.0 + input) * 43.0521);
    // return frac(frac(input * 2709.11) * input * 443.21);
    // return 0.0;
}

// hash functions from 1 to 4 inputs

float n11 (float input) {
    return n11_a(input);
}

float n22 (float2 input) {
    return float2(n11_a(input.x), n11_b(input.y));
}

float n21 (float2 input) {
    // return frac(
    //     127.189 * n11_a(input.x) * n11_b(input.y) 
    //     + 824.193 * n11_c(input.x + input.y)
    // );
    float a =  n11_a(input.x);
    float b =  n11_b(input.y);
    return frac(127.189 * frac(
        n11_a(a * b) + 
        n11_b(b * a)
    ));
}

float n33 (float3 input) {
    return float3(n11_a(input.x), n11_b(input.y), n11_c(input.z));
}

float n31 (float3 input)  {
    // return frac(
    //     1270.189 * n11_a(input.x) * n11_b(input.y) * n11_c(input.z) 
    //     + 824.193 * n11_c(input.x + input.y + input.z)
    // );
    float a =  n11_a(input.x);
    float b =  n11_b(input.y);
    float c =  n11_c(input.z);
    return frac(1270.189 * frac(
        n11_a(a * b) + 
        n11_b(b * c) + 
        n11_c(c * a)
    ));
}

float n44 (float4 input) {
    return float4(n11_a(input.x), n11_b(input.y), n11_c(input.z), n11_d(input.w));
}

float n41 (float4 input) {
    // return frac(
    //     12700.189 * n11_a(input.x) * n11_b(input.y) * n11_c(input.z) * n11_d(input.w)
    //     + 824.193 * n11_a(input.x + input.y + input.z + input.w)
    // );
    float a =  n11_a(input.x);
    float b =  n11_b(input.y);
    float c =  n11_c(input.z);
    float d =  n11_d(input.w);
    return frac(12700.189 * frac(
        n11_a(a * b) + 
        n11_b(b * c) + 
        n11_c(c * d) + 
        n11_d(d * a))
    );
}

// perlin noise

float perlin1 (float input) {
    float x1 = floor(input.x);
    float x2 = x1 + 1.0;
    float lx = smoothstep(0, 1, frac(input.x));
    return lerp(n11(x1), n11(x2), lx);
}

float perlin2 (float2 input) {
    float2 floorInput = floor(input);
    float noise[4];
    for(uint i=0; i<4; i++){
        uint dx = (i / 2);
        uint dy = (i % 2);
        noise[i] = n21(float2(floorInput.x + dx, floorInput.y + dy));
    }
    float2 fracInput = smoothstep(0, 1, frac(input));
    // float2 fracInput = frac(input);
    float lerpA[2] = {
        lerp(noise[0], noise[1], fracInput.y),
        lerp(noise[2], noise[3], fracInput.y)
    };
    return lerp(lerpA[0], lerpA[1], fracInput.x);
}

float perlin3 (float3 input) {
    float3 floorInput = floor(input);
    float noise[8];
    for(uint i=0; i<8; i++){
        uint dx = i / 4;
        uint dy = (i % 4) / 2;
        uint dz = i % 2;
        noise[i] = n31(float3(floorInput.x + dx, floorInput.y + dy, floorInput.z + dz));
    }
    float3 fracInput = smoothstep(0, 1, frac(input));
    // float3 fracInput = frac(input);
    float lerpA[4] = {
        lerp(noise[0], noise[1], fracInput.z),
        lerp(noise[2], noise[3], fracInput.z),
        lerp(noise[4], noise[5], fracInput.z),
        lerp(noise[6], noise[7], fracInput.z)
    };
    float lerpB[2] = {
        lerp(lerpA[0], lerpA[1], fracInput.y),
        lerp(lerpA[2], lerpA[3], fracInput.y)
    };
    return lerp(lerpB[0], lerpB[1], fracInput.x);
}

float perlin4 (float4 input) {
    float4 floorInput = floor(input);
    float noise[16];
    for(uint i=0; i<16; i++){
        uint dx = i / 8;
        uint dy = (i % 8) / 4;
        uint dz = (i % 4) / 2;
        uint dw = i % 2;
        noise[i] = n41(float4(floorInput.x + dx, floorInput.y + dy, floorInput.z + dz, floorInput.w + dw));
    }
    float4 fracInput = smoothstep(0, 1, frac(input));
    // float4 fracInput = frac(input);
    float lerpA[8] = {
        lerp(noise[0], noise[1], fracInput.w),
        lerp(noise[2], noise[3], fracInput.w),
        lerp(noise[4], noise[5], fracInput.w),
        lerp(noise[6], noise[7], fracInput.w),
        lerp(noise[8], noise[9], fracInput.w),
        lerp(noise[10], noise[11], fracInput.w),
        lerp(noise[12], noise[13], fracInput.w),
        lerp(noise[14], noise[15], fracInput.w)
    };
    float lerpB[4] = {
        lerp(lerpA[0], lerpA[1], fracInput.z),
        lerp(lerpA[2], lerpA[3], fracInput.z),
        lerp(lerpA[4], lerpA[5], fracInput.z),
        lerp(lerpA[6], lerpA[7], fracInput.z)
    };
    float lerpC[2] = {
        lerp(lerpB[0], lerpB[1], fracInput.y),
        lerp(lerpB[2], lerpB[3], fracInput.y)
    };
    return lerp(lerpC[0], lerpC[1], fracInput.x);
}

// clouds noise

float clouds1 (float input, uint iterations) {
    float output = 0.0;
    float pos = input;
    float maxSum = 0.0;
    for(uint i=0; i<iterations; i++){
        float multiplier = 1.0 / (i + 1);
        float noise = 0.5 - perlin1(pos);
        output += multiplier * noise;
        maxSum += multiplier;
        pos *= 2.0;
    }
    output += maxSum / 2.0;
    return output / maxSum;
}

float clouds2 (float2 input, uint iterations) {
    float output = 0.0;
    float2 pos = input;
    float maxSum = 0.0;
    for(uint i=0; i<iterations; i++){
        float multiplier = 1.0 / (i + 1);
        float noise = 0.5 - perlin2(pos);
        output += multiplier * noise;
        maxSum += multiplier;
        pos *= 2.0;
    }
    output += maxSum / 2.0;
    return output / maxSum;
}

float clouds3 (float3 input, uint iterations) {
    float output = 0.0;
    float3 pos = input;
    float maxSum = 0.0;
    for(uint i=0; i<iterations; i++){
        float multiplier = 1.0 / (i + 1);
        float noise = 0.5 - perlin3(pos);
        output += multiplier * noise;
        maxSum += multiplier;
        pos *= 2.0;
    }
    output += maxSum / 2.0;
    return output / maxSum;
}

float clouds4 (float4 input, uint iterations) {
    float output = 0.0;
    float4 pos = input;
    float maxSum = 0.0;
    for(uint i=0; i<iterations; i++){
        float multiplier = 1.0 / (i + 1);
        float noise = 0.5 - perlin4(pos);
        output += multiplier * noise;
        maxSum += multiplier;
        pos *= 2.0;
    }
    output += maxSum / 2.0;
    return output / maxSum;
}