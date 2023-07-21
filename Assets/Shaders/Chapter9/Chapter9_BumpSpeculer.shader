Shader "MyShader/Chapter9_BumpSpeculer"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map",2D) = "bump"{}
        _Speculaer("Speculer",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _BumpMap;
            fixed4 _BumpMap_ST;
            fixed4 _Speculaer;
            float _Gloss;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                fixed3 worldPos = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(worldPos);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
                
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldPos = fixed3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                bump = normalize( half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse  = _LightColor0.rgb *  albedo * saturate(dot(bump,worldLightDir));

                fixed3 halfDir = normalize(worldViewDir + worldLightDir);
                fixed3 speculaer = _LightColor0.rgb * _Speculaer.rgb * pow(saturate(dot(bump,halfDir)),_Gloss);
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4(ambient + (diffuse + speculaer)*atten,1);
            }
            ENDCG
        }
    
        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdadd

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

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _BumpMap;
            fixed4 _BumpMap_ST;
            fixed4 _Speculaer;
            float _Gloss;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                fixed3 worldPos = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(worldPos);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent).xyz;
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
                
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldPos = fixed3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                bump = normalize( half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
                fixed3 diffuse  = _LightColor0.rgb *  albedo * saturate(dot(bump,worldLightDir));

                fixed3 halfDir = normalize(worldViewDir + worldLightDir);
                fixed3 speculaer = _LightColor0.rgb * _Speculaer.rgb * pow(saturate(dot(bump,halfDir)),_Gloss);
                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                return fixed4((diffuse + speculaer)*atten,1);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
