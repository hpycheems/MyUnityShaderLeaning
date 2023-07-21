Shader "Unlit/Chapter15_WaterWave"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _WaveMap ("Wave Map", 2D) = "bump" {}
        _Cubemap ("Environment Cubemap", Cube) = "_Skyobx" {}
        _WaveXSpeed ("Wave X Speed", Range(-0.1, 0.1)) = 0
        _WaveYSpeed ("Wave Y Speed", Range(-0.1, 0.1)) = 0
        _Distortion ("Distortion", Range(0, 1000)) = 20
    }
    SubShader
    {
        Tags {"RenderType"="Opaque" "Queue"="Transparent"}

        GrabPass{"_ReflectionTex"}

        pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _WaveMap;
            fixed4 _WaveMap_ST;
            samplerCUBE _Cubemap;
            fixed _WaveXSpeed;
            fixed _WaveYSpeed;
            float _Distortion;
            sampler2D _ReflectionTex;
            float4 _ReflectionTex_TexelSize;

            struct v2f{
                float4 pos : SV_POSITION;
                float4 srcPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            v2f vert(appdata_full v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.srcPos = ComputeGrabScreenPos(o.pos);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = fixed4(worldTangent.x, worldBinormal.x, worldNormal.x , worldPos.x);
                o.TtoW1 = fixed4(worldTangent.y, worldBinormal.y, worldNormal.y , worldPos.y);
                o.TtoW2 = fixed4(worldTangent.z, worldBinormal.z, worldNormal.z , worldPos.z);

                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float speed = _Time.y * fixed2(_WaveXSpeed, _WaveYSpeed);

                fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
                fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
                fixed3 normal = normalize(bump1 + bump2);

                float2 offset = normal.xy * _Distortion * _ReflectionTex_TexelSize.xy;
                i.srcPos.xy = offset * i.srcPos.z + i.srcPos.xy;
                fixed3 refrCol = tex2D(_ReflectionTex, i.srcPos.xy / i.srcPos.w).rgb;

                normal = normalize(half3(dot(i.TtoW0.xyz, normal), dot(i.TtoW1.xyz, normal), dot(i.TtoW2.xyz, normal)));
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflDir = reflect(-viewDir, normal);
                fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb * _Color.rgb;

                fixed fresnel = pow(1 - saturate(dot(viewDir, normal)), 4);
                fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);

                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
