Shader "MyShader/Chapter10_Refraction01"
{
    Properties
    {
        _Color("Tint Color",Color) =(1,1,1,1)
        _RefractColor("Refract Color",Color)=(1,1,1,1)
        _RefractAmount("Refract Amount",Range(0,1))=1
        _RefractRatio("Refract Ratio",Range(0,1)) = 0.5
        _Cubemap("Cube map",Cube) ="_sykbox"{}
    }
    SubShader
    {
        Tags{"RenderType"="Opaque"}
        pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
            samplerCUBE _Cubemap;

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldRefract :TEXCOORD3;
                SHADOW_COORDS(4)
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefract = refract(normalize(-o.worldViewDir),normalize(o.worldNormal),_RefractRatio);
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));
                fixed3 refractColor = texCUBE(_Cubemap,i.worldRefract).rgb * _RefractColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color = ambient + lerp(diffuse,refractColor,_RefractAmount)*atten;
                return fixed4(color,1);

            }
            ENDCG
        }
    }
    Fallback "diffuse"
}
