Shader "MyShader/Chapter9_BumpedDiffuse"
{
    Properties
    {
       _Color("Color",Color)=(1,1,1,1)
       _BumpMap("Normal Map",2D)="bump"{}
       _MainTex("Main Tex",2D)="white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        pass{
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase

            fixed4 _Color;
            sampler2D _BumpMap;
            fixed4 _BumpMap_ST;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                fixed4 TtoW0 : TEXCOORD1;
                fixed4 TtoW1 : TEXCOORD2;
                fixed4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };
            v2f vert(appdata_tan v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                fixed3 worldPos = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 = fixed4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = fixed4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = fixed4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed3 worldPos = fixed3(i.TtoW0.z,i.TtoW1.z,i.TtoW2.z);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 worldNormal = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
               worldNormal = normalize(half3(dot(i.TtoW0.xyz,worldNormal),dot(i.TtoW1.xyz,worldNormal),dot(i.TtoW2.xyz,worldNormal)));

                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);
                return fixed4(ambient + diffuse * atten , 1 );
            }
            ENDCG
        }
        pass{
            Tags { "LightMode"="ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd

            fixed4 _Color;
            sampler2D _BumpMap;
            fixed4 _BumpMap_ST;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                fixed4 TtoW0 : TEXCOORD1;
                fixed4 TtoW1 : TEXCOORD2;
                fixed4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };
            v2f vert(appdata_tan v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                fixed3 worldPos = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 = fixed4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = fixed4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = fixed4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed3 worldPos = fixed3(i.TtoW0.z,i.TtoW1.z,i.TtoW2.z);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 worldNormal = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                worldNormal = normalize(half3(dot(i.TtoW0.xyz,worldNormal),dot(i.TtoW1.xyz,worldNormal),dot(i.TtoW2.xyz,worldNormal)));

                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);
                return fixed4(diffuse * atten,1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
