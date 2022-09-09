Shader "_lil/PrintingLit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        // Printing
        [Header(Printing)][Space]
        _PatternScaleX ("Scale X", Float) = 1024
        _PatternScaleY ("Scale Y", Float) = 1024
        _PatternBlur ("Blur", Float) = 1
        [Toggle(APPLY_NOISE)] _ApplyNoise ("Noise", Int) = 0
        _NoiseStrength ("Noise Strength", Range(0,0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.5
        #pragma shader_feature_local _ APPLY_NOISE

        #include "Printing.hlsl"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        float4 _Color;

        float _PatternScaleX;
        float _PatternScaleY;
        float _PatternBlur;
        float _NoiseStrength;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float4 col = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            #if defined(APPLY_NOISE)
                o.Albedo = lilAMScreening(col.rgb, IN.uv_MainTex, float2(_PatternScaleX,_PatternScaleY), _PatternBlur, _NoiseStrength);
            #else
                o.Albedo = lilAMScreening(col.rgb, IN.uv_MainTex, float2(_PatternScaleX,_PatternScaleY), _PatternBlur);
            #endif

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = col.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
