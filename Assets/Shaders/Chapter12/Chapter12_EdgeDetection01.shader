Shader "Unlit/Chapter12_EdgeDetection"
{
    Properties
    {
        _MainTex ("Main Tex",2D) = "white"{}
        _EdgeColor("Edges Color",Color) = (1,1,1,1)
        _EdgesOnly("Edge Only",Range(0,1)) = 1
        _BackGroundColor("Background Color",Color) = (1,1,1,1)
    }
    SubShader{
        pass{
            ZTest Always
            Cull off 
            ZWrite off
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            fixed4 _MainTex_TexelSize;
            fixed4 _EdgeColor;
            fixed _EdgesOnly;
            fixed4 _BackGroundColor;

            struct OutPut{
                float4 pos : SV_POSITION;
                half2 uv[9] : TEXCOORD0;
            };

            OutPut vert(appdata_base v){
                OutPut o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;

                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1,0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0,1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,1);

                return o;
            }
            half lnminance(fixed4 color){
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            fixed Sobel(OutPut i){
                const fixed Gx[9] = {
                    -1,-2,-1,
                    0,0,0,
                    1,2,1
                };
                const fixed Gy[9] = {
                     -1,0,1,
                    -2,0,2,
                    -1,0,1
                } ;
                fixed texColor;
                fixed edgeX;
                fixed edgeY;
                for(int it = 0; it < 9; it++ ){
                    texColor = lnminance(tex2D(_MainTex, i.uv[it]));
                    edgeX += texColor * Gx[it];
					edgeY += texColor * Gy[it];
                }
                return 1 - abs(edgeX) - abs(edgeY);
            }

            fixed4 frag(OutPut i):SV_Target{
                fixed edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackGroundColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgesOnly);
            }

            ENDCG
        }
    }
}
