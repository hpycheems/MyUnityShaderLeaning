Shader "Unlit/Chapter12_BrightnessSaturaionAndCountrast"
{
    Properties
    {
        _MainTex("Base (RGB)",2D) = "white"{}
        _Saturation("Saturation",Float) = 1
        _Brightness("Brightness",Float) = 1
        _Contrast("Contrast",Float) = 1
    }
    SubShader
    {
        pass{
            ZTest Always
            ZWrite off 
            Cull off 

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _Saturation;
            float _Brightness;
            float _Contrast;

            struct v2f{
                float4 pos :SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_img v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed4 c = tex2D(_MainTex,i.uv);
                fixed3 finalColor = c.rgb * _Brightness;

                fixed luminance = 0.2125 * c.r + 0.7154 * c.g + 0.0721 * c.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);
                finalColor = lerp(luminanceColor,finalColor,_Saturation);

                fixed3 avgColo = fixed3(0.5,0.5,0.5);
                finalColor = lerp(avgColo,finalColor,_Contrast);

                return fixed4(finalColor,c.a);
            }
            ENDCG
        }
    }
}
