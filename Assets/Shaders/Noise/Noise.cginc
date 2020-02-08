// individual hash functions

float n11_a (float input) {
    return frac(frac(input * 2234.57) * input * 357.13);
}

float n11_b (float input) {
    return frac(frac(input * 3187.91) * input * 298.79);
}

float n11_c (float input) {
    return frac(frac(input * 3521.43) * input * 313.77);
}

float n11_d (float input) {
    return frac(frac(input * 2709.11) * input * 443.21);
}

// hash functions from 1 to 4 inputs

float n11 (float input) {
    return n11_a(input);
}

float n21 (float2 input) {
    return frac(n11_a(input.x) + n11_b(input.y));
}

float n31 (float3 input)  {
    return frac(n11_a(input.x) + n11_b(input.y) + n11_c(input.z));
}

float n41 (float4 input) {
    return frac(n11_a(input.x) + n11_b(input.y) + n11_c(input.z) + n11_d(input.w));
}