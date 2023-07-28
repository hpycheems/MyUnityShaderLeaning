Shader "Unlit/GlassRefraction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bunpmap ("Normal Map", 2D) = "bump"{}
        _Cubemap ("Cube Map", Cube) = "_skybox"{}
        _Distortion ("Distortion", Range(0, 100)) = 1
        _RefractAmount ("Refract Amount", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "Queue" = "Transparent"
        }
        LOD 100

        GrabPass{ "_RefractionTex" }
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                float4 srcPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bunpmap;
            float4 _Bunpmap_ST;
            samplerCUBE _Cubemap;
            fixed _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.srcPos = ComputeGrabScreenPos(o.pos);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _Bunpmap);

                float3 worldPos = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangnet = UnityObjectToWorldDir(v.tangent);
                fixed3 worldBinormal = cross(worldTangnet, worldNormal) * v.tangent.w;

                o.TtoW0 = float4(worldTangnet.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangnet.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangnet.z, worldBinormal.z, worldNormal.z, worldPos.z);


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                fixed3 halfDir = normalize(worldViewDir + worldLightDir);

                fixed3 bump = UnpackNormal(tex2D(_Bunpmap, i.uv.zw));
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.srcPos.xy = offset * i.srcPos.z + i.srcPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.srcPos.xy / i.srcPos.w).rgb;

                bump = normalize(fixed3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

                fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
                return fixed4(finalColor, 1);
            }
            ENDHLSL
        }
    }
}
