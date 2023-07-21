Shader "Unlit/Blinn-Phong_Function"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tine", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        pass{
            Tags{
                "LightMode" = "ForwardBase"
            }
            HLSLPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            half4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _SpecularColor;
            fixed _Gloss;

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                float3 worldPos = i.worldPos;
                float3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed diff = max(0, dot(worldLightDir, worldNormal));
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * diff;
                
                half3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed spec = pow(saturate(dot(worldNormal, halfDir)), _Gloss);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * spec;

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDHLSL
        }
    }
}
