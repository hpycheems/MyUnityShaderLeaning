Shader "MyShader/Chapter9_AlphaTestAndShadow"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff("Alpha Cutoff",Range(0,1))=0.5
    }
    SubShader
    {
        Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 worldNormal :TEXCOORD1;
                fixed3 worldPos :TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord ,_MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex,i.uv);
                clip(texColor.a - _Cutoff);
                // if((texColor.a - _Cutoff)<0.0){
                //     discard;
                // }
                fixed3 albedo  = texColor.rgb  * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                return fixed4(ambient + diffuse * atten,1.0);
            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}
