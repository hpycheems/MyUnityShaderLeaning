// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SampleShader"
{
    Properties{}
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

            float4 vert(float4 v : POSITION) : SV_POSITION{
                return UnityObjectToClipPos(v);
            }
            float4 frag():SV_Target{
                return float4(1,1,1,1);
            }
            ENDHLSL
        }
    }
}
