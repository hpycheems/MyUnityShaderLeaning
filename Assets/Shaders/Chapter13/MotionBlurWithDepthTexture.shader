Shader "Unlit/MotionBlurWithDepthTexture"
{
    // Properties
    // {
    //     _MainTex ("Texture", 2D) = "white" {}
    //     _BlurSize ("Blur Size", Float) = 0.1
    // }
    // SubShader
    // {
    //     CGINCLUDE
    //     #include "UnityCG.cginc"

    //     sampler2D _MainTex;
    //     fixed4 _MainTex_TexelSize;
    //     float _BlurSize;
    //     sampler2D _CameraDepthTexture;//深度图
    //     float4x4 _CurrentViewProjectionInverseMatrix;//当前视角 * 投影变换的逆变换
    //     float4x4 _PreviousViewProjectionMatrix;

    //     struct v2f{
    //         float4 pos : SV_POSITION;
    //         float2 uv : TEXCOORD0;
    //         float2 uv_depth : TEXCOORD1;
    //     };

    //     v2f vert(appdata_base v){
    //         v2f o;
    //         o.pos = UnityObjectToClipPos(v.vertex);

    //         o.uv = v.texcoord;
    //         o.uv_depth = v.texcoord;

    //         #if UNITY_UV_STARTS_AT_TOP
    //         if(_MainTex_TexelSize.y < 0){
    //             o.uv_depth.y = 1 - o.uv_depth.y;
    //         }
    //         #endif
    //         return o;
    //     }

    //     fixed4 frag(v2f i):SV_Target{
    //         float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);//得到映射([0,1])后的深度值

    //         float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1.0f);//把得到的深度值映射会NDC深度值[-1,1]

    //         float4 D = mul(_CurrentViewProjectionInverseMatrix, H);//把获得的DNC坐标变换回世界空间

    //         float4 worldPos = D / D.w;//齐次除法得到世界空间坐标

    //         float4 currenPos = H;

    //         float4 previousePos = mul(_PreviousViewProjectionMatrix, worldPos);

    //         previousePos /= previousePos.w;

    //         float velocity = (currenPos.xy - previousePos.xy)/2.0f;

    //         float2 uv = i.uv;
    //         float4 c = tex2D(_MainTex, uv);
    //         uv += velocity * _BlurSize;
    //         for(int it = 1; it < 3; it++, uv += velocity * _BlurSize){
    //             float4 currentColor = tex2D(_MainTex, uv);
    //             c += currentColor;
    //         }
    //         c /= 2;
    //         return fixed4(c.rgb, 1);
    //     }

    //     ENDCG
    //     pass{
    //         ZTest Always
    //         ZWrite off 
    //         Cull off 
    //         CGPROGRAM
    //         #pragma vertex vert 
    //         #pragma fragment frag 
    //         ENDCG
    //     }
    // }
    Properties
    {
        _MainTex ("RGB:Base", 2D) = "white" {}
        _BlurSize ("模糊大小" , Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;     float4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;      //Unity传递过来的深度纹理
        float4x4 _PreviousViewProjectionMatrix;         //脚本传来：变化矩阵WS->NDC ,  前一帧的NDC位置
        float4x4 _CurrentViewProjectionInverseMatrix;   //脚本传来：变化矩阵NDC->WS ,  当前帧的WS位置
        half _BlurSize;

        struct appdata {
            float4 vertex : POSITION;
            float2 uv0 : TEXCOORD0;
        };

        struct v2f {
            float4 pos : SV_POSITION;
            float2 uv0 :TEXCOORD0; 
            float2 uv_depth :TEXCOORD1;  //用于采样深度纹理
        };

        v2f vert (appdata v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv0 = v.uv0;
            o.uv_depth = v.uv0;
            
            #if UNITY_UV_STARTS_AT_TOP      //去除平台化差异，防止开启抗锯齿带来多个渲染纹理出现uv错误
            if (_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1 - o.uv_depth.y;
            #endif

            return o;
        }

        half4 frag(v2f i) : SV_TARGET {
            //【计算速度】
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture , i.uv_depth);   //采样深度图，获取深度值
            #if defined(UNITY_REVERSED_Z)       //宏定义：是否进行了深度取反
                d = 1.0 - d;
            #endif

            float4 H = float4(i.uv0.x*2 - 1 , i.uv0.y*2 - 1 ,  d*2 - 1 , 1);   //从深度值到NDC坐标

            float4 D = mul(_CurrentViewProjectionInverseMatrix , H);       // NDC乘逆变换矩阵
            float4 posWS = D / D.w;     // 获取世界空间坐标

            float4 previousPos = mul(_PreviousViewProjectionMatrix , posWS);    //前一帧齐次裁剪坐标
            previousPos /= previousPos.w;       //前一帧NDC坐标

            float4 currentPos = H;      //当前帧NDC坐标

            float2 velocity =(currentPos.xy - previousPos.xy) / 2.0f;   //速度范围[-1,1]

            //【用速度偏移uv，进行采样】
            float2 uv = i.uv0;
            float4 c = tex2D(_MainTex , uv);
            uv += velocity * _BlurSize;     //uv偏移
            for (int it = 1 ; it < 3 ; it++ , uv += velocity * _BlurSize) {
                float4 currentCol = tex2D(_MainTex , uv);   //用新uv采样_MainTex
                c +=currentCol;     //c的颜色叠加
            }
            c /= 3;     //三次采样后的结果取平均

            return half4(c.rgb , 1.0);
        }

        ENDCG

        Pass
        {
            
            ZTest Always ZWrite Off Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
