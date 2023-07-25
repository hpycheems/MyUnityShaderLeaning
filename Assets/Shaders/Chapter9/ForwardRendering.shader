Shader "Unlit/ForwardRendering"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
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
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                //o.worldNormal = mul(v.normal, float3x3(unity_WorldToObject))
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               float3 worldPos = i.worldPos;
               float3 worldNormal = normalize(i.worldNormal);
               float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
               float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
               half3 halfDir = normalize(worldLightDir + worldViewDir);

               fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

               fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
               fixed3 specualr = _LightColor0.rgb * _Specular * pow(max(0, dot(worldNormal, halfDir)) , _Gloss);
               UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
               fixed3 color = ambient + (diffuse + specualr) * atten;

               return fixed4(color, 1);
            }
            ENDHLSL
        }
        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                //o.worldNormal = mul(v.normal, float3x3(unity_WorldToObject))
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               float3 worldPos = i.worldPos;
               float3 worldNormal = normalize(i.worldNormal);
               fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
               fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
            //    #ifndef USING_DIRECTIONAL_LIGHT
            //     float3 worldViewDir = normalize(_WorldSpaceLightPos0.xyz);
            //    #elif
            //     float3 worldViewDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);
            //    #endif
               half3 halfDir = normalize(worldLightDir + worldViewDir);

               fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

               fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
               fixed3 specualr = _LightColor0.rgb * _Specular * pow(max(0, dot(worldNormal, halfDir)) , _Gloss);

               UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

               fixed3 color = (diffuse + specualr) * atten;

               return fixed4(color, 1);
            }
            ENDHLSL
        }
    }
    Fallback "Diffuse"
}
