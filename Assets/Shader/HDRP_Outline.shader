Shader "Custom/Outline"
{
    HLSLINCLUDE

#pragma vertex Vert

#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone vulkan metal switch

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

// The PositionInputs struct allow you to retrieve a lot of useful information for your fullScreenShader:
// struct PositionInputs
// {
//     float3 positionWS;  // World space position (could be camera-relative)
//     float2 positionNDC; // Normalized screen coordinates within the viewport    : [0, 1) (with the half-pixel offset)
//     uint2  positionSS;  // Screen space pixel coordinates                       : [0, NumPixels)
//     uint2  tileCoord;   // Screen tile coordinates                              : [0, NumTiles)
//     float  deviceDepth; // Depth from the depth buffer                          : [0, 1] (typically reversed)
//     float  linearDepth; // View space Z coordinate                              : [Near, Far]
// };

// To sample custom buffers, you have access to these functions:
// But be careful, on most platforms you can't sample to the bound color buffer. It means that you
// can't use the SampleCustomColor when the pass color buffer is set to custom (and same for camera the buffer).
// float4 SampleCustomColor(float2 uv);
// float4 LoadCustomColor(uint2 pixelCoords);
// float LoadCustomDepth(uint2 pixelCoords);
// float SampleCustomDepth(float2 uv);

// There are also a lot of utility function you can use inside Common.hlsl and Color.hlsl,
// you can check them out in the source code of the core SRP package.


    float4 _OutlineColor;
    float _Thickness;
    float _Threshold;
    float _Opacity;

    //TEXTURE2D_X(_BaseColorMap);
    TEXTURE2D_X(_MaskTexture);
    TEXTURE2D_X(_MainTexture);

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        // When sampling RTHandle texture, always use _RTHandleScale.xy to scale your UVs first.
        float2 uv = posInput.positionNDC.xy * _RTHandleScale.xy;

        //_Maintexture is laodable with LoadCustomColor and with Texture via SAMPLE_TEXTURE2D_X_LOD
        // LoadCustomColor(posInput.positionSS);
        float4 maskingObject = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv, 0);
        float4 mainTex = SAMPLE_TEXTURE2D_X_LOD(_MainTexture, s_linear_clamp_sampler, uv, 0);
        mainTex.a = 0;

        //shows the selected object
        if (maskingObject.r > 0)
            return mainTex;

        // use masking texture for colering and to sample outline
        half a1 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2(-1,  1), 0).r;
        half a2 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2( 0,  1), 0).r;
        half a3 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2( 1,  1), 0).r;

        half a4 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2(-1,  0), 0).r;
        half a5 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2( 0,  0), 0).r;
        half a6 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2( 1,  0), 0).r;
        
        half a7 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2(-1, -1), 0).r;
        half a8 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2( 0, -1), 0).r;
        half a9 = SAMPLE_TEXTURE2D_X_LOD(_MaskTexture, s_linear_clamp_sampler, uv + _ScreenSize.zw * _RTHandleScale.xy * _Thickness * float2( 1, -1), 0).r;
        
        //kernel gradients
        half gx = a1 + a2  + a3 + a7 + a8  + a9 + a5;
        half gy = a1 + a4  + a7 + a3 + a6  + a9 + a5;
        
        half w = sqrt(gx * gx + gy * gy);
        
        //branching for debugging we use lerp for this
        //if (w > 0.1)
            //return _OutlineColor;
        //else
            //return w;

        //Luminance(maskingObject.rgb)
        return lerp(_OutlineColor, w, step(w, 0.5)) *_Opacity;
         
        
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Outline Pass"

            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
                #pragma fragment FullScreenPass

            ENDHLSL
        }
    }
    Fallback Off
}
