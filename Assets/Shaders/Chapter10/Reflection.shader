Shader "Unlit/Reflection"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ReflectColor ("Reflect Color", Color) = (1, 1, 1, 1)
        _ReflectAmount ("Reflect Amount", Range(0, 1)) = 0.5
        _CubeMap ("Cube map", Cube) = "_skybox"{}
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
            }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            samplerCUBE _CubeMap;
            fixed4 _ReflectColor;
            fixed _ReflectAmount;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = i.worldPos;
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse =_LightColor0.rgb * _Color * max(0, dot(worldNormal, worldLightDir));
                fixed3 reflection = texCUBE(_CubeMap, i.worldRefl).rgb * _ReflectColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffse"
}
