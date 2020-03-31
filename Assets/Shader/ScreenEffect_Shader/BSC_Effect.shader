Shader "Custom/BSC_Effect"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BrighnessAmount("Brightness Amount", Range(0.0, 1)) = 1.0
        _satAmount("Saturation Amount", Range(0.0, 1)) = 1.0 
        _conAmount("Contrast Amount", Range(0.0, 1)) = 1.0

    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
                #pragma vertex vert_img
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"

                uniform sampler2D _MainTex;
                fixed _BrighnessAmount;
                fixed _satAmount;
                fixed _conAmount;


                //helper function
                float3 ContrastSaturationBrightness(float3 color, float3 brt, float3 sat, float3 con)
                {
                    //adjustment for each color channel
                    float AvgLumR = 0.5;
                    float AvgLumG = 0.5;
                    float AvgLumB = 0.5;

                    //Luminance coefficients for getting luminance from image
                    float3 LuminanceCoeff   = float3(0.2125, 0.7154, 0.0721);


                    //operation for Brightness
                    float3 AvgLumin         = float3(AvgLumR, AvgLumG, AvgLumB);
                    float3 brtColor         = color * brt;
                    float intensityf        = dot(brtColor, LuminanceCoeff);
                    float intensity         = float3(intensityf, intensityf, intensityf);

                    //operation for Saturation
                    float3 satColor         = lerp(intensity, brtColor, sat); 

                    //operation for contrast
                    float3 conColor         = lerp(AvgLumin, satColor, con);
                    return conColor;
                }

                fixed4 frag(v2f_img i) : COLOR
                {
                    //Get Color from RenderTexture and UVs
                    //from the v2f_img struct            
                    fixed4 renderTex    = tex2D(_MainTex, i.uv);
                    renderTex.rgb       = ContrastSaturationBrightness
                                        (
                                            renderTex.rgb,
                                            _BrighnessAmount,
                                            _satAmount,
                                            _conAmount
                                        );
                    return renderTex;
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
