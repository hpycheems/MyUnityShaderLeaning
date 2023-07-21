Shader "Unlit/Chapter15_FogWithNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogDensity ("Fog Density", Float) = 0
        _FogColor ("Fog Color", Color) = (1, 1, 1, 1)
        _FogStart ("Fog Start", Float) = 0
        _FogEnd ("Fog End", Float) = 2
        _NoiseAmount ("Noise Amount", Float) = 0
        _FogXSpeed ("Noise X Speed", Float) = 0
        _FogYSpeed ("Noise Y Speed", Float) = 0
        _NoiseTexture ("Noise Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        float4x4 _FrustumCorners;

        sampler2D _MainTex;
        fixed4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity;
        fixed4 _FogColor;
        fixed _FogStart;
        fixed _FogEnd;
        half _NoiseAmount;
        fixed _FogXSpeed;
        fixed _FogYSpeed;
        sampler2D _NoiseTexture;

        struct v2f{
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float2 uv_depth : TEXCOORD1;
            float4 interpolatedRay : TEXCOORD2;
        };

        v2f vert(appdata_full v){
            v2f o; 
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            int index = 0;
            if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5){
                index = 0;
            }else if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5){
                index = 1;
            }else if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5){
                index = 2;
            }else{
                index = 3;
            }

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                o.uv_depth.y = 1 - o.uv_depth.y;
            }

            if(_MainTex_TexelSize.y < 0){
                index = 3 - index;
            }
            #endif

            o.interpolatedRay = _FrustumCorners[index];
            return o;
        }
        fixed4 frag(v2f i):SV_Target{
            float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
            float3 worldPos = _WorldSpaceCameraPos + depth * i.interpolatedRay.xyz;

            float2 speed = _Time.y * float2(_FogXSpeed, _FogYSpeed);
            float noise = (tex2D(_NoiseTexture, i.uv + speed).r - 0.5) * _NoiseAmount;

            float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
            fogDensity = saturate(fogDensity * _FogDensity * (1 + noise));

            fixed4 finalColor = tex2D(_MainTex, i.uv);
            finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

            return finalColor;
        }
        ENDCG

        pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            ENDCG
        }
    }
    Fallback off
}
