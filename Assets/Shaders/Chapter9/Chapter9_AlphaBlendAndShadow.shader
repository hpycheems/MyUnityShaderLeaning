Shader "MyShader/Chapter9_AlphaBlendAndShadow"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("Alpha Scale",Range(0,1))=1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProject"="True" "RenderType"="Transparent" }
        Pass
        {
            Tags{"LigheMode"="ForwardBase"}
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

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

                fixed3 albedo  = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                return fixed4(ambient+diffuse * atten ,texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    Fallback "Transparent"
}
