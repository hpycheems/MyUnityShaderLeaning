Shader "MyShader/Chapter10_Fresnel01"
{
    Properties
    {
       _Color("Tint Color",Color)=(1,1,1,1)
       _FresnelScale("Fresnel Scale",Range(0,1)) = 0.5
       _Cubemap("Cube map",Cube) = "_skybox"{}
    }
    SubShader
    {
        Tags{"RenderMode"="Opaque"}
        pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            fixed _FresnelScale;
            samplerCUBE _Cubemap;

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldReflect : TEXCOORD3;
                SHADOW_COORDS(4)
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldReflect = reflect(-o.worldViewDir,o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb *_Color.rgb *saturate(dot(worldNormal,worldLightDir));
                fixed3 reflectColor = texCUBE(_Cubemap,i.worldReflect).rgb ;
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1-dot(worldViewDir,worldNormal),5);
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color = ambient + lerp(diffuse,reflectColor,saturate(fresnel)) * atten;
                return fixed4(color,1);
            }
            ENDCG
        }
        
    }
    Fallback "diffuse"
}
