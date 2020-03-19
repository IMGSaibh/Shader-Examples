Shader "Custom/Transparent"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        // _Glossiness ("Smoothness", Range(0,1)) = 0.5
        // _Metallic ("Metallic", Range(0,1)) = 0.0
        _Transparancy("Transparency", Range(0.0,1.0)) = 0.5
    }
    SubShader
    {
        //Tag Transparent -> Unity draw glass last, but dont draw pixels that belongs
        //to geometry hidden behind something else [Z-Buffering]
        Tags 
        { 
            "RenderType"="Opaque"
            "IgnoreProjector" = "True"
            "Queue" = "Transparent"
        }

        Cull Back
        LOD 200

        CGPROGRAM
            #pragma surface surf Standard alpha:fade

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            sampler2D _MainTex;
            float _Transparancy;

            struct Input
            {
                float2 uv_MainTex;
            };

            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                // Albedo comes from a texture tinted by color
                fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                // Metallic and smoothness come from slider variables
                o.Alpha = c.a * _Transparancy;
            }
        ENDCG
    }
    FallBack "Diffuse"
}
