Shader "MyShader/Chapter11_BillBoard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Tint Color",Color)=(1,1,1,1)
        _VerticalBillBoarding("Vertical Restarints",Range(0,1))=1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProject"="True" "Queue"="Transparent" "DisableBatching"="True" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            ZWrite off
            Blend SrcAlpha OneminusSrcAlpha
            Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _VerticalBillBoarding;

            struct v2f
            {
                float4 pos :SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            
            v2f vert (appdata_base v)
            {
                v2f o;

                fixed3 center = fixed3(0,0,0);
                fixed3 viewer = mul(unity_WorldToObject,fixed4(_WorldSpaceCameraPos,1));

                fixed3 normalDir = viewer - center;
                normalDir.y = normalDir.y * _VerticalBillBoarding;
                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y)> 0.999 ? float3(0,0,1) : float3(0,1,0);
                float3 rightDir = normalize(cross(normalDir ,upDir));
                upDir = normalize(cross(normalDir,rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
                o.pos = UnityObjectToClipPos(float4(localPos,1));
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
                
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *=_Color.rgb;
                return c;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
