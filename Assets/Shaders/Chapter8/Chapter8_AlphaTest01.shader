Shader "Unlit/Chapter8_AlphaTest01"
{
    Properties{
        _Color ("Color",Color) = (1,1,1,1)
        _MainTex ("Main Tex",2D) = "while"{}
        _Cutoff ("Cut Off",Range(0,1)) = 0.5
    }
    SubShader{
        Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        pass{
            Tags{"LightModel"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _Cutoff;

            struct v2f{
                float4 pos : SV_POSITION;
                fixed3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed2 uv : TEXCOORD2;
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex,i.uv);
                clip(texColor.a - _Cutoff);
                fixed3 albedo = _Color.rgb * texColor.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

                return fixed4(ambient + diffuse,1.0);
            }

            ENDCG
        }
    }
}
