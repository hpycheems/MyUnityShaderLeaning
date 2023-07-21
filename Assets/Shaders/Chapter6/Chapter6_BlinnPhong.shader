Shader "MyShader/Chapter6_BlinnPhong"
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
                fixed3 worldNormal :TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                //o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                //o.worldPos = UnityObjectToWorldDir(v.vertex);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed3 worldPos = i.worldPos;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));
                fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                //fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                fixed3 halfDir = normalize(worldViewDir+worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
                return fixed4(ambient+diffuse+specular,1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
