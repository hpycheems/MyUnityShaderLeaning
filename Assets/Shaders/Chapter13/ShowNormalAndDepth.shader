Shader "Unlit/ShowNormalAndDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags{"RenderType"="Opaque"}
        CGINCLUDE
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;
        fixed4  _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;

        struct v2f{
            float4 pos : SV_POSITION;
            float2 uv_depth : TEXCOORD0;
        };

        v2f vert(appdata_base v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv_depth = v.texcoord.xy;
            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                o.uv_depth.y = 1 - o.uv_depth.y;
            }
            #endif
            return o;
        }
        fixed4 frag(v2f i):SV_Target{
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            float lieanrDepth = Linear01Depth(d);
            return fixed4(lieanrDepth, lieanrDepth, lieanrDepth, 1);
        }
        ENDCG
        
        pass{
            ZTest Always
            ZWrite off 
            Cull off 
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            ENDCG
        }
    }
}
