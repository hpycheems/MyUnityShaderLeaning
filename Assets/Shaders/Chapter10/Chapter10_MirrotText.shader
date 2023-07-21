Shader "MyShader/Chapter10_MirrotText"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            
            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv: TEXCOORD0;
            };
            v2f vert(appdata_base v){
                v2f o ;
                o.pos =UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv.x = 1-o.uv.x;
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                return tex2D(_MainTex,i.uv);
            }
            
            ENDCG
        }
    }
}
