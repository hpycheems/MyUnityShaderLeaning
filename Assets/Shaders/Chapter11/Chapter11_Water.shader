Shader "MyShader/Chapter11_Water"
{
    Properties
    {
        _Color("Tint Color",Color)=(1,1,1,1)
        _MainTex("Main Texture",2D)="white"{}
        _Frequency("Frequency",Float)=1
        _Magnitude("Magnitude",Float)=1
        _InvWaveLength("Wave Length",Float)=10
        _Speed("Speed",Float)=1
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
            #include "UnityCG.cginc "

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _Frequency;
            float _Magnitude;
            float _Speed;
            float _InvWaveLength;

            struct v2f{
               float4 pos :SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            v2f vert(appdata_base v){
                v2f o;
                float4 offset;
                offset.yzw = float3(0,0,0);
                // offset.x = sin(_Frequency * _Time.y ) * _Magnitude;
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength
                     + v.vertex.z * _InvWaveLength) * _Magnitude;
                o.pos = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv += float2(0,_Time.y * _Speed);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
