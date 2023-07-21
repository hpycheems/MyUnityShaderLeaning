Shader "Unlit/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bloom ("Bloom Tex", 2D) = "while" {}
        _BlurSize ("Blur Size", Float) = 1
        _LuminanceThreshold ("Luminance Threshold", Float) = 0.5
    }
    SubShader
    { 
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        fixed4 _MainTex_TexelSize;
        sampler2D _Bloom;
        fixed _BlurSize;
        fixed _LuminanceThreshold;

        struct BrightOutPut{
            float4 pos : SV_POSITION;
            fixed2 uv : TEXCOORD0;
        };

        BrightOutPut vertExtractBright(appdata_img v){
            BrightOutPut o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed luminance(fixed4 color){
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        fixed4 fragExtractBright(BrightOutPut i):SV_Target{
            fixed4 bloomTex = tex2D(_MainTex, i.uv);
            fixed bloomValue = clamp(luminance(bloomTex) - _LuminanceThreshold, 0, 1);
            return bloomTex * bloomValue;
        }

        struct BlendOutPut{
            float4 pos : SV_POSITION;
            fixed4 uv : TEXCOORD0;
        };

        BlendOutPut vertBlend(appdata_img v){
            BlendOutPut o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                o.uv.w = 1.0 - o.uv.w;
            }
            #endif

            return o;
        }

        fixed4 fragBlend(BlendOutPut i):SV_Target{
            fixed4 mainTexColor = tex2D(_MainTex, i.uv.xy);
            fixed4 bloomTexColor = tex2D(_Bloom, i.uv.zw);
            return mainTexColor + bloomTexColor;
        }

        ENDCG

        ZTest Always
        ZWrite off 
        Cull off 
        pass{
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }
        UsePass "Custom/Chapter12_GaussainBlru/GAUSSAIN_BLUR_VERTICAL"
        UsePass "Custom/Chapter12_GaussainBlru/GAUSSAIN_BLUR_HORIZONTAL"
        pass{
            CGPROGRAM
            #pragma vertex vertBlend
            #pragma fragment fragBlend
            ENDCG
        }
    }
    Fallback "off"
}
