Shader "Unlit/Chapter14_ToonShading"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Ramp ("Ramp", 2D) = "while"{}
        _Outline ("Out Line", Range(0, 1)) = 0.1
        _OutlineColor ("Out Line Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.1
    }
    SubShader
    {
        pass{
            NAME "OUTLINE"
            Cull Front 
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"

            fixed _Outline;
            fixed4 _OutlineColor;

            struct v2f{
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v){
                v2f o;

                float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                normal.z = -0.5;
                pos = pos + float4(normalize(normal), 0) * _Outline;
                o.pos = mul(UNITY_MATRIX_P, pos);

                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                return fixed4(_OutlineColor.rgb, 1);
            }   

            ENDCG
        }
        pass{
            Tags {"LigheMode"="ForwardBase"}
            Cull Back
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _Ramp;
            fixed4 _Specular;
            fixed _SpecularScale;

            struct v2f{
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 normal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(lightDir + viewDir);

                fixed4 c = tex2D(_MainTex, i.uv);
                fixed3 albedo = c.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                float diff = dot(normal, lightDir);
                diff = (diff * 0.5 + 0.5) * atten;
                fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, fixed2(diff, diff)).rgb;

                fixed spec = dot(normal, halfDir);
                fixed w = fwidth(spec) * 2.0;
                fixed3 specular = _Specular * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1) * step(0.0001, _SpecularScale));

                return fixed4(ambient + diffuse + specular , 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
