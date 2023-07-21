Shader "MyShader/Chapter11_ImageSequenceAnimation"
{
    Properties
    {
       _MainTex("MainTexture",2D)="white"{}
       _Color("Tint Color",Color)=(1,1,1,1)
       _HorizontalAmount("Horizontal Amount",Float)=4
       _VerticalAmount("Vertical Amount",Float)=4
       _Speed("Speed",Float)=0.5
    }
    SubShader
    {
        Tags{
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "IgnoreProject"="True"
            "DisableBatching"="True"
        }
        pass{
            Tags{"LightMode"="ForwardBase"}
            ZWrite off 
            Blend SrcAlpha OneminusSrcAlpha
            Cull off 
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;
            fixed4 _Color;

            struct v2f{
              float4 pos : SV_POSITION;
              float2 uv : TEXCOORD0;  
            };
            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed time = floor(_Time.y * _Speed);
                fixed row = floor(time / _HorizontalAmount);
                fixed column = time - row * _VerticalAmount;

                half2 uv = half2(i.uv.x/_HorizontalAmount,i.uv.y/_VerticalAmount);
                uv.x += column/_HorizontalAmount;
                uv.y -= row/_VerticalAmount;
                return tex2D(_MainTex,uv) * _Color;

            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
