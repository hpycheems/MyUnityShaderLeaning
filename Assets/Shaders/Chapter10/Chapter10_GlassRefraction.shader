Shader "MyShader/Chapter10_GlassRefraction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex("Normal Map",2D)="bump"{}
        _Cubemap("Cube Map",Cube)="_skybox"{}
        _Distortion("Distortion",Range(0,100))=10 //控制物体折射的扭曲程度
        _RefractAmount("Refract Amount",Range(0,1))=1 //控制物体反射和折射的效果
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "RenderType"="Opaque"}
        GrabPass { "_RefractionTex" }
        pass{
            
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                sampler2D _MainTex;
                fixed4 _MainTex_ST;
                sampler2D _BumpTex;
                fixed4 _BumpTex_ST;
                samplerCUBE _Cubemap;
                float _Distortion;
                fixed _RefractAmount;
			    sampler2D _RefractionTex;
			    float4 _RefractionTex_TexelSize;

                struct v2f{
                    float4 pos : SV_POSITION;
                    float4 uv :TEXCOORD0;
                    float4 TtoW0:TEXCOORD1;
                    float4 TtoW1:TEXCOORD2;
                    float4 TtoW2:TEXCOORD3;
                    float4 scrPos : TEXCOORD4;
                };

                v2f vert(appdata_tan v){
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.scrPos = ComputeGrabScreenPos(o.pos);

                    o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
                    o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpTex);

                    fixed3 worldPos = UnityObjectToWorldDir(v.vertex).xyz;
                    fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                    fixed3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;

                    o.TtoW0 = fixed4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                    o.TtoW1 = fixed4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                    o.TtoW2 = fixed4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                    return o;
                }

                fixed4 frag(v2f i):SV_Target{
                    fixed3 worldPos = fixed3(i.TtoW0.x,i.TtoW1.z,i.TtoW2.z);
                    fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                    

                    float3 bump = UnpackNormal(tex2D(_BumpTex,i.uv.zw));

                    fixed2 offset = bump.xy *_Distortion * _RefractionTex_TexelSize.xy;//使用切线空间下的法线来进行偏移，原因该空间下的法线可以反应顶点局部空间下的法线方向。
                    i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;

                    fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;// 使用进行透视除法后的纹理坐标 对抓取的屏幕图像 进行采样

                    bump = normalize( half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                    fixed3 reflDir = reflect(-worldViewDir,bump);
                    fixed4 textCol = tex2D(_MainTex,i.uv.xy);
                    fixed3 reflCol = texCUBE(_Cubemap,reflDir).rgb * textCol.rgb;

                    fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
                    
                    return fixed4(finalColor,1);
                }

            ENDCG
        }
    }
}
