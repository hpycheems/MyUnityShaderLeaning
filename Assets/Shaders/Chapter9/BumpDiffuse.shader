Shader "Unlit/BumpDiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump"{}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _BumpScale ("Bump Scale", Range(1, 20)) = 1
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
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Color;
            fixed _BumpScale;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = UnityObjectToWorldDir(v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityObjectToViewPos(worldPos));
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);

                float3 worldNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                worldNormal.xy *= _BumpScale;
                worldNormal.z = sqrt(1.0 - max(0, dot(worldNormal.xy, worldNormal.xy)));
                worldNormal = normalize(float3(dot(i.TtoW0.xyz, worldNormal), dot(i.TtoW1.xyz, worldNormal), dot(i.TtoW2.xyz, worldNormal)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb *_Color;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                fixed3 color = ambient + diffuse * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
        
        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Color;
            fixed _BumpScale;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = UnityObjectToWorldDir(v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityObjectToViewPos(worldPos));
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);

                float3 worldNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                worldNormal.xy *= _BumpScale;
                worldNormal.z = sqrt(1.0 - max(0, dot(worldNormal.xy, worldNormal.xy)));
                worldNormal = normalize(float3(dot(i.TtoW0.xyz, worldNormal), dot(i.TtoW1.xyz, worldNormal), dot(i.TtoW2.xyz, worldNormal)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb *_Color;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                fixed3 color = diffuse * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}
