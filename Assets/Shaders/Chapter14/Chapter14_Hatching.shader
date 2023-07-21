Shader "Unlit/Chapter14_Hatching"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _TileFactor ("Tile Factor", Float) = 1
        _Outline ("Out Line", Range(0, 1)) = 0.1
        _Hatch0 ("Hatch0", 2D) = "while"{}
        _Hatch1 ("Hatch1", 2D) = "while"{}
        _Hatch2 ("Hatch2", 2D) = "while"{}
        _Hatch3 ("Hatch3", 2D) = "while"{}
        _Hatch4 ("Hatch4", 2D) = "while"{}
        _Hatch5 ("Hatch5", 2D) = "while"{}
    }
    SubShader
    {
        Tags {"RenderType"="Opaque" "Queue"="Geometry"}
        UsePass "Unlit/Chapter14_ToonShading/OUTLINE"

        pass{
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert 
            #pragma fragment frag 

            #pragma multi_compile_fwdbase

            fixed4 _Color;
            float _TileFactor;
            sampler2D _Hatch0;
            sampler2D _Hatch1;
            sampler2D _Hatch2;
            sampler2D _Hatch3;
            sampler2D _Hatch4;
            sampler2D _Hatch5;

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 hatchWeights0 : TEXCOORD1;
                fixed3 hatchWeights1 : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _TileFactor;

                o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed diff = saturate(dot(worldNormal, worldLightDir));

                o.hatchWeights0 = fixed3(0, 0, 0);
                o.hatchWeights1 = fixed3(0, 0, 0);

                float hatchFactor = diff * 7.0;

                if(hatchFactor > 6.0){
                    
                }else if(hatchFactor > 5.0){
                    o.hatchWeights0.x = hatchFactor - 5.0;
                }else if(hatchFactor > 4.0){
                    o.hatchWeights0.x = hatchFactor - 4.0;
                    o.hatchWeights0.y = 1 - o.hatchWeights0.x;
                }else if(hatchFactor > 3.0){
                    o.hatchWeights0.y = hatchFactor - 3.0;
                    o.hatchWeights0.z = 1 - o.hatchWeights0.y;
                }else if(hatchFactor > 2.0){
                    o.hatchWeights0.z = hatchFactor - 2.0;
                    o.hatchWeights1.x = 1 - o.hatchWeights0.z;
                }else if(hatchFactor > 1.0){
                    o.hatchWeights1.x = hatchFactor - 1.0;
                    o.hatchWeights1.y = 1 - o.hatchWeights1.x;
                }else{
                    o.hatchWeights1.y = hatchFactor;
                    o.hatchWeights1.z = 1 - o.hatchWeights1.y;
                }

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed4 hatchTex0 = tex2D(_Hatch0, i.uv) * i.hatchWeights0.x;
                fixed4 hatchTex1 = tex2D(_Hatch1, i.uv) * i.hatchWeights0.y;
                fixed4 hatchTex2 = tex2D(_Hatch2, i.uv) * i.hatchWeights0.z;
                fixed4 hatchTex3 = tex2D(_Hatch3, i.uv) * i.hatchWeights1.x;
                fixed4 hatchTex4 = tex2D(_Hatch4, i.uv) * i.hatchWeights1.y;
                fixed4 hatchTex5 = tex2D(_Hatch5, i.uv) * i.hatchWeights1.z;

                fixed4 whiteColor = fixed4(1, 1, 1, 1) * (1 - i.hatchWeights0.x - i.hatchWeights0.y - i.hatchWeights0.z - 
                    i.hatchWeights1.x - i.hatchWeights1.y - i.hatchWeights1.z);
                fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + whiteColor;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                return fixed4(hatchColor.rgb * _Color.rgb * atten, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
