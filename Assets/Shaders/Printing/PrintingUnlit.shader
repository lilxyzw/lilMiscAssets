Shader "_lil/PrintingUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        // Printing
        _PatternScaleX ("Scale X", Float) = 1024
        _PatternScaleY ("Scale Y", Float) = 1024
        _PatternBlur ("Blur", Float) = 1
        [Toggle(APPLY_NOISE)] _ApplyNoise ("Noise", Int) = 0
        _NoiseStrength ("Noise Strength", Range(0,0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma target 3.5
            #pragma shader_feature_local _ APPLY_NOISE
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Printing.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PatternScaleX;
            float _PatternScaleY;
            float _PatternBlur;
            float _NoiseStrength;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);

                #if defined(APPLY_NOISE)
                    col.rgb = lilAMScreening(col.rgb, i.uv, float2(_PatternScaleX,_PatternScaleY), _PatternBlur, _NoiseStrength);
                #else
                    col.rgb = lilAMScreening(col.rgb, i.uv, float2(_PatternScaleX,_PatternScaleY), _PatternBlur);
                #endif

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}