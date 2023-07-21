Shader "MyShader/Chapter10_Reflection01"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _ReflectColor("Reflection Color",Color)=(1,1,1,1)
        _ReflectAmount("Reflact Amount",Range(0,1))=1
        _Cubemap("Cube map",Cube)="sky_box"{}
    }
    SubShader
    {
        Tags{"RednderMode"="Opaque"}
        pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _ReflectColor;
            fixed _ReflectAmount;
            samplerCUBE _Cubemap;

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldViewDir : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldRefl = reflect(-o.worldViewDir,o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldPos = i.worldPos;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));
                fixed3 reflectColor = texCUBE(_Cubemap,i.worldRefl).rgb * _ReflectColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);
                fixed3 color = ambient + lerp(diffuse,reflectColor,_ReflectAmount) * atten;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
