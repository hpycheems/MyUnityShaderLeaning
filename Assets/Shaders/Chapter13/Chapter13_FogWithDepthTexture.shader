Shader "Unlit/Chapter13_FogWithDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogStart ("Fog Start", Float) = 0
        _FogEnd ("Fog End", Float) = 2
        _FogDencity ("Fog Dencity", Float) = 1
        _FogColor ("Fog Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        float4x4 _FrustumCornersRay;

        sampler2D _MainTex;
        fixed4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDencity;
        half _FogStart;
        half _FogEnd;
        float _E;
        fixed4 _FogColor;

        struct v2f{
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 depth_uv : TEXCOORD1;
            float4 interpolatedRay : TEXXCOORD2;
        };

        v2f vert(appdata_base v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.depth_uv = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                o.depth_uv.y = 1.0f - o.depth_uv.y;
            }
            #endif

            int index = 0;
            if(v.texcoord.x < 0.5f && v.texcoord.y < 0.5f){
                index = 0;
            }
            else if(v.texcoord.x > 0.5f && v.texcoord.y < 0.5f){
                index = 1;
            }
            else if(v.texcoord.x > 0.5f && v.texcoord.y > 0.5f){
                index = 2;
            }
            else{
                index = 3;
            }

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                index = 3 - index;
            }
            #endif

            o.interpolatedRay = _FrustumCornersRay[index];
            return o;
        }

        fixed4 frag(v2f i):SV_Target{
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.depth_uv));
            float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay;

            float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
            fogDensity = saturate(fogDensity * _FogDencity);

            //float fogDensity = pow(_E, -_FogDencity * abs(worldPos.y));

            fixed4 finalColor = tex2D(_MainTex, i.uv);
            finalColor.rgb = lerp(finalColor.rgb, _FogColor, fogDensity);

            return finalColor;
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
    Fallback off 
}
