Shader "MyShader/Chapter6_DiffuseVertexLevel"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;

            struct v2f{
                float4 pos : SV_POSITION;
                fixed3 color : TEXCOORD0;
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));
                o.color = ambient+ diffuse;
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                return fixed4(i.color,1.0);
            }
            
            ENDCG
        }
    }
    Fallback "Diffuse"
}
