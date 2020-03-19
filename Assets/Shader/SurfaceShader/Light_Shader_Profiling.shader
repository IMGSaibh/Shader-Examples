Shader "Custom/Light_Shader_Profiling"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "White" {}
        _NormalMap ("Normal Map ", 2D) = "bump" {}
        _BlendTex("Blend Texture", 2D) = "White" {}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf SimpleLambert exclude_path:prepass noforwardadd

        sampler2D   _MainTex;
        sampler2D   _NormalMap;
        sampler2D   _BlendTex;

        struct Input
        {
            //optimization use half2 instead of float2
            half2 uv_MainTex;
            half2 uv_NormalMap;
        };

        //fixed4 instead float4
        inline fixed4 LightingSimpleLambert(SurfaceOutput s, float3 lightDir, float3 atten)
        {
            //fixed instead of float
            fixed diff  = max(0, dot(s.Normal, lightDir));

            fixed4 c;
            c.rgb       = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
            c.a         = s.Alpha;
            return c; 

        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            //also here
            fixed4 c        = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 blendTex = tex2D(_BlendTex, IN.uv_MainTex);
            c               = lerp(c, blendTex, blendTex.r); 
            o.Albedo        = c.rgb;
            o.Alpha         = c.a;
            //use IN.uv_MainTex instead of IN.uv_NormalMap to share UVs between Normal Map and diffuse Texture
            o.Normal        = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
        }

        ENDCG
    }
    Fallback "Diffuse"
}
