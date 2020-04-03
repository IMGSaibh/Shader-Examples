Shader "Custom/ModularShaderExample_light"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DesatValue ("Desaturate", Range(0,1)) = 0.5
        //defined in MyCginlclude
        _LightColor ("My Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		LOD 200
        CGPROGRAM
            #include "CgInclude_Light.cginc"
            #pragma surface surf HalfLambert

            #pragma target 3.0

            struct Input
            {
                float2 uv_MainTex;
            };

            sampler2D _MainTex; 
            fixed4 _DesatValue;

            void surf (Input IN, inout SurfaceOutput o)
            {
			    half4 c = tex2D (_MainTex, IN.uv_MainTex); 
			    c.rgb = lerp(c.rgb, Luminance(c.rgb), _DesatValue); 
                o.Albedo = c.rgb;
                o.Alpha = c.a;
            }
        ENDCG
    }
    FallBack "Diffuse"
}
