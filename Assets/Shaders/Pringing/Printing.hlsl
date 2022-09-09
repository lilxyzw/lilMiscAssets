float2 lilRotateUV(float2 uv, float angle)
{
    float si,co;
    sincos(angle, si, co);
    float2 outuv = uv - 0.5;
    outuv = float2(
        outuv.x * co - outuv.y * si,
        outuv.x * si + outuv.y * co
    );
    outuv += 0.5;
    return outuv;
}

float4 lilAMScreeningPattern(float2 uv, float dd)
{
    float4 uvCM, uvYK;
    uvCM.xy = lilRotateUV(uv, 15.0 / 180.0 * 3.14159265359);
    uvCM.zw = lilRotateUV(uv, 75.0 / 180.0 * 3.14159265359);
    uvYK.xy = lilRotateUV(uv,  0.0 / 180.0 * 3.14159265359);
    uvYK.zw = lilRotateUV(uv, 45.0 / 180.0 * 3.14159265359);
    float4 dotCM = frac(uvCM) - 0.5;
    float4 dotYK = frac(uvYK) - 0.5;
    dotCM *= dotCM;
    dotYK *= dotYK;
    float4 lengthCMYK = sqrt(float4(dotCM.x+dotCM.y, dotCM.z+dotCM.w, dotYK.x+dotYK.y, dotYK.z+dotYK.w) * 2.0);
    lengthCMYK = saturate(lengthCMYK - lengthCMYK * dd + dd); //lerp(lengthCMYK, 1.0, dd);
    lengthCMYK = saturate(lengthCMYK * 0.95 + 0.025); // remove noise
    return lengthCMYK;
}

float3 lilRGB2CMYK(float3 col, float4 lengthCMYK, float dd, float ddOrig)
{
    float3 RGB = col;
    #if !UNITY_COLORSPACE_GAMMA
        RGB = pow(RGB + 0.001, 1.0/2.2);
    #endif
    float RGBMax = max(max(RGB.r, RGB.g), RGB.b);
    float4 CMYK = 1.001 - float4(RGB * rcp(RGBMax), RGBMax);

    CMYK = sqrt(CMYK);
    float4 printCMYK = saturate((lengthCMYK - CMYK) / dd);
    float blending = saturate(ddOrig * 3.0 - 2.0 + abs(dot(col,0.333333) - 0.5) * 2);
    return printCMYK.xyz * (printCMYK.w - printCMYK.w * blending) + col * blending; //lerp(printCMYK.xyz * printCMYK.w, col, blending);
}

float3 lilAMScreening(float3 col, float2 uv, float2 scale, float blur)
{
    float2 uvScaled = uv * scale;
    float ddOrig = fwidth(abs(uvScaled.x) + abs(uvScaled.y));
    float dd = saturate(ddOrig * blur);
    float4 lengthCMYK = lilAMScreeningPattern(uvScaled, dd);
    return lilRGB2CMYK(col, lengthCMYK, dd, ddOrig);
}

float3 lilAMScreening(float3 col, float2 uv, float2 scale, float blur, float noiseStrength)
{
    float2 uvScaled = uv * scale;
    float ddOrig = fwidth(abs(uvScaled.x) + abs(uvScaled.y));
    float dd = saturate(ddOrig * blur);
    float4 lengthCMYK = lilAMScreeningPattern(uvScaled, dd);

    float ddNoise = saturate(ddOrig*2);
    noiseStrength = noiseStrength - noiseStrength * ddNoise;
    float noise = abs(frac(uvScaled.x * 3.0158516) - 0.5) + abs(frac(uvScaled.x * 2.7159816) - 0.5);
    noise +=      abs(frac(uvScaled.y * 3.6274217) - 0.5) + abs(frac(uvScaled.y * 2.2731362) - 0.5);
    noise +=      abs(frac((uvScaled.x+uvScaled.y) * 3.6274217) - 0.5) + abs(frac((uvScaled.x+uvScaled.y) * 2.2731362) - 0.5);
    noise +=      abs(frac((uvScaled.x-uvScaled.y) * 3.1636172) - 0.5) + abs(frac((uvScaled.x-uvScaled.y) * 2.4631762) - 0.5);
    lengthCMYK = saturate(lengthCMYK * (1 - noiseStrength * 2) + noiseStrength);
    lengthCMYK += noise * noiseStrength - noiseStrength * 2;

    return lilRGB2CMYK(col, lengthCMYK, dd, ddOrig);
}