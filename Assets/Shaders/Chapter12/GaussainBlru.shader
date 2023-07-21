Shader "Unlit/GaussainBlru"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("BlurSize",Float) = 1
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        fixed4 _MainTex_TexelSize;
        fixed _BlurSize;

        struct OutPut{
            float4 pos : SV_POSITION;
            fixed2 uv[5] : TEXCOORD0;
        };

        OutPut vertBlurVertical(appdata_img v){
            OutPut o;
            o.pos = UnityObjectToClipPos(v.vertex);
            fixed2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + float2(0, _MainTex_TexelSize.y * 1) * _BlurSize;
            o.uv[2] = uv - float2(0, _MainTex_TexelSize.y * 1) * _BlurSize;
            o.uv[3] = uv + float2(0, _MainTex_TexelSize.y * 2) * _BlurSize;
            o.uv[4] = uv - float2(0, _MainTex_TexelSize.y * 2) * _BlurSize;

            return o;
        }
        OutPut vertBlurHorizontal(appdata_img v){
            OutPut o;
            o.pos = UnityObjectToClipPos(v.vertex);
            fixed2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1, 0) * _BlurSize;
            o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1, 0) * _BlurSize;
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2, 0) * _BlurSize;
            o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2, 0) * _BlurSize;

            return o;
        }

        fixed4 blurFrag(OutPut i):SV_Target{
            fixed weight[] = {0.4026, 0.2442, 0.0545};
            fixed3 sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];
            for(int it = 1; it < 3; it++){
                sum += tex2D(_MainTex,i.uv[it * 2 - 1]).rgb * weight[it];
                sum += tex2D(_MainTex,i.uv[it * 2]).rgb * weight[it];
            }
            return fixed4(sum,1.0f);
        }
        ENDCG
        
        ZTest Always
        ZWrite off 
        Cull off 
        pass{
            NAME "GAUSSAIN_BLUR_VERTICAL"
            CGPROGRAM
            #pragma vertex vertBlurVertical 
            #pragma fragment blurFrag 

            ENDCG
        }
        pass{
            NAME "GAUSSAIN_BLUR_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment blurFrag
            ENDCG
        }
    }
}
