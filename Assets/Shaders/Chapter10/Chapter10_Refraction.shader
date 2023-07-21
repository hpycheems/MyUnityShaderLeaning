Shader "MyShader/Chapter10_Refraction"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _RefractColor("Refraction Color",Color)=(1,1,1,1)
        _RefractAmount("Refraction Amount",Range(0,1))=1
        _RefractRatio("Refraction Ratio",Range(0,1))=0.5
        _CubeMap("Refraction CubeMap",Cube)="_skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
            samplerCUBE _CubeMap;


            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldViewDir : TEXCOORD1;
                fixed3 worldPos : TEXCOORD2;
                float3 worldRefr : TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefr = refract(-normalize( o.worldViewDir),normalize(o.worldNormal),_RefractRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir  = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));
                
                fixed3 refraction = texCUBE(_CubeMap,i.worldRefr).rgb * _RefractColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color =ambient + lerp(diffuse,refraction,_RefractAmount) * atten ;
                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
}
