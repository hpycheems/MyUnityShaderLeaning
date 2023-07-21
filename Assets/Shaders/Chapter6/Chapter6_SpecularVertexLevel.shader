Shader "MyShader/Chapter6_SpecularVertexLevel"
{
    Properties
    {
        _Color("Color Tin",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
    }
    SubShader
    {
        pass{
            Tags{"LigheMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color :TEXCOORD0;
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));
                //由于CG的reflect函数的入射方向要求是由光源指向交点处的，因此需要对worldLightDir取反后再传给reflect函数。
                fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
                fixed3 viewDir =normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                o.color = ambient+diffuse +specular;

                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                return fixed4(i.color,1.0);
            }
            ENDCG
        }

    }
    Fallback "Specular"
}
