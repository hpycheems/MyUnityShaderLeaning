Shader "Unlit/AlphaBlenZWrite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }
        LOD 100

        Pass
        {
            ZWrite on
            ColorMask 0
        }
        pass{
            Tags{"LightMode" = "ForwardBase"}
                ZWrite off 
                Blend SrcAlpha OneMinusSrcAlpha
                HLSLPROGRAM
                #pragma vertex vert 
                #pragma fragment frag 

                #include "UnityCG.cginc"
                #include "Lighting.cginc"

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                    float3 worldNormal : TEXCOORD2;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed4 _Color;
                fixed _AlphaScale;

                v2f vert (appdata_base v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                    o.worldNormal = UnityObjectToWorldNormal(v.normal);
                    o.worldPos = UnityObjectToWorldDir(v.vertex);
                    return o;
                }

                fixed4 frag (v2f i) : SV_Target
                {
                    float3 worldPos = i.worldPos;
                    float3 worldNormal = normalize(i.worldNormal);
                    fixed3 worldLightDir = UnityWorldSpaceLightDir(worldPos);

                    fixed4 texColor = tex2D(_MainTex, i.uv);
                    fixed3 albedo = texColor.rgb * _Color;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                    fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                    return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
                }
                ENDHLSL
            
        }
    }
}
