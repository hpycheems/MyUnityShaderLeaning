Shader "Unlit/Chapter12_Bloom"
{
    Properties
    {
        _MainTex("Base (RGB)",2D)="white"{}
        _BlurSize("Blur Size",Float)=1
        _Bloom("Bloom",2D)="black"{}
        _LuminanceThreshold("Luminance Threshold",Float)=0.5
    }
    SubShader
    {
        CGINCLUDE
        sampler2D _MainTex;
        fixed4 _MainTex_TexelSize;
        float _BlurSize;
        sampler2D _Bloom;
        float _LuminanceThreshold;
        #include "UnityCG.cginc"
        
        struct v2f{
            float4 pos :SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vertExtractBright(appdata_img v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        fixed luminace(fixed4 color){
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }
        fixed4 fragExtractBright(v2f i):SV_Target{
            fixed4 c = tex2D(_MainTex,i.uv);
            fixed val = clamp(luminace(c) - _LuminanceThreshold,0,1);
            return c * val;
        }
        struct v2fBloom{
            float4 pos : SV_POSITION;
            half4 uv : TEXCOORD0;
        };
        v2fBloom vertBloom(appdata_img v){
            v2fBloom o;
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
        fixed4 fragBlomm(v2fBloom i):SV_Target{
            return  tex2D(_Bloom,i.uv.zw) + tex2D(_MainTex,i.uv.xy) ;
        }
        ENDCG
        
        ZTest Always 
        Cull off 
        ZWrite off 
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
            #pragma vertex vertBloom
            #pragma fragment fragBlomm
            ENDCG
        }
    }
}
