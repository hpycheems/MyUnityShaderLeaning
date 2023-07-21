// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SampleShader"
{
    Properties{
        _Color ("Color Tine", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
            };



            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5f + fixed3(0.5, 0.5, 0.5);
                return o;
            }
            float4 frag(v2f i) : SV_Target{
                fixed3 c = i.color;
                c *= _Color.rgb;
                return float4(c ,1);
            }
            ENDHLSL
        }
    }
}
