Shader "MyShader/Chapter9_Shadow"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

            struct v2f{
                float4 pos :SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                fixed atten = 1.0;
                fixed shadow = SHADOW_ATTENUATION(i);
                return fixed4(ambient + (diffuse + specular) * atten * shadow,1.0);
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
            #pragma multi_compile_fwdadd
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed3 _Specular;
            float _Gloss;

            struct v2f{
                float4 pos :SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif
                
                
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
                #ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w 
						* tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif
                fixed shadow = SHADOW_ATTENUATION(i);
                return fixed4(ambient + (diffuse + specular) * atten * shadow,1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
