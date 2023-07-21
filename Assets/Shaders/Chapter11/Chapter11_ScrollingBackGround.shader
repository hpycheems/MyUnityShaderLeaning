Shader "MyShader/Chapter11_ScrollingBackGround"
{
    Properties
    {
       _MainTex("Base Layer",2D) = "white"{}
       _DetailTex("2nd Layer",2D)="white"{}
       _ScrollX("ScrollX Speed",Float)=1
       _Scroll2X("Scroll2X Speed",Float)=1
       _Mutiplier("Layer Mutiplier",Float)=1
    }
    SubShader
    {
        Tags{"RenderType"="Opaque"}
        pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _DetailTex;
            fixed4 _DetailTex_ST;
            float _Scroll2X;
            float _ScrollX;
            float _Mutiplier;

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex) + frac(float2(_ScrollX,0)*_Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_DetailTex)+ frac(float2(_Scroll2X,0)*_Time.y);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex,i.uv.zw);

                fixed4 c = lerp(firstLayer,secondLayer,secondLayer.a);
                c.rgb *= _Mutiplier;
                return c;
            }
            ENDCG
        }
        
    }
    Fallback "VertexLit"
}
