Shader "MyShader/Chapter10_Reflection"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _ReflectColor("Reflection Color",Color)=(1,1,1,1)
        _ReflectAmount("ReflectAmount",Range(0,1))=1
        _CubeMap("Reflection Cubemap",Cube)="_skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _ReflectColor;
            fixed _ReflectAmount;
            samplerCUBE _CubeMap;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldViewDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert (appdata_base v)
            {
                v2f o;
                //o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefl = reflect(-o.worldViewDir,o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;

            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir  = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));

                fixed3 reflection = texCUBE(_CubeMap,i.worldRefl).rgb * _ReflectColor.rgb ;
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color = ambient + lerp(diffuse , reflection,_ReflectAmount) * atten;
                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
}
