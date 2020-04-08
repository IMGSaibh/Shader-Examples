Shader "Custom/VFACE"
{
    Properties
    {

    }
    SubShader
    {
        cull off

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 5.0


        struct Input
        {
            float IsFacing:VFACE;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 color = (IN.IsFacing > 0) ? float4(1,0,0,1) : float4(0,0,1,1);
            o.Emission = color.rgb;
            o.Alpha = color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
