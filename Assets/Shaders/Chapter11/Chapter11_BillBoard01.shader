Shader "MyShader/Chapter11_BillBoard"
{
    Properties
    {
        _MainTex("Main Trxture",2D)="white"{}
        _Color("Color Tint",Color)=(1,1,1,1)
        _VerticalBillborading("Vertical Restraints",Range(0,1))=1
    }
    SubShader
    {
       Tags{
        "Queue"="Transparent" 
        "IgnoreProject"="True"
        "DisableBatching"="True"
        "RenderType"="Transparent"
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
       float _VerticalBillborading;
       fixed4 _Color;

       struct v2f{
            float4 pos :SV_POSITION;
            float2 uv : TEXCOORD0;
       };

        v2f vert(appdata_base v){
            v2f o;
            float3 center = float3(0,0,0);
            float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));

            float3 normalDir = viewer - center;
            normalDir.y = normalDir.y * _VerticalBillborading;
            normalDir = normalize(normalDir);

            //float3 upDir = abs(normalDir.y)>0.999? float3(0,0,1):float(0,1,0);
            float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
            float3 rightDir = normalize(cross(normalDir,upDir));
            upDir = normalize(cross(normalDir,rightDir));

            float3 centerOffset = v.vertex - center;
            float3 localPos = center + upDir * v.vertex.y + rightDir * v.vertex.x + normalDir * v.vertex.z;
            o.pos = UnityObjectToClipPos(float4(localPos,1));
            o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
            return o;
        }
        fixed4 frag(v2f i):SV_Target{
            float4 c = tex2D(_MainTex,i.uv);
            c.rgb *= _Color.rgb;
            return c;
        }
       ENDCG
       }
    }
    Fallback "Transparent/VertexLit"
}
