Shader "Custom/MaskingShader"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone vulkan metal switch

    // #pragma enable_d3d11_debug_symbols

    //enable GPU instancing support
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "MaskingPassOutline"

            //Blend Off
            //ZWrite Off
            //ZTest LEqual

            Cull Back

            HLSLPROGRAM
            
            // List all the attributes needed in your shader (will be passed to the vertex shader)
            // you can see the complete list of these attributes in VaryingMesh.hlsl
            //#define ATTRIBUTES_NEED_TEXCOORD0
            //#define ATTRIBUTES_NEED_NORMAL
            //#define ATTRIBUTES_NEED_TANGENT

            // List all the varyings needed in your fragment shader
            //#define VARYINGS_NEED_TEXCOORD0
            //#define VARYINGS_NEED_TANGENT_TO_WORLD
            
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderers.hlsl"


            // If you need to modify the vertex datas, you can uncomment this code
            // Note: all the transformations here are done in object space
            // #define HAVE_MESH_MODIFICATION
            // AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
            // {
            //     input.positionOS += input.normalOS * 0.0001; // inflate a bit the mesh to avoid z-fight
            //     return input;
            // }

            // Put the code to render the objects in your custom pass in this function
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                #ifdef _ALPHATEST_ON
                    DoAlphaTest(opacity, _AlphaCutoff);
                #endif

                // Write back the data to the output structures
                ZERO_INITIALIZE(BuiltinData, builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.emissiveColor = float3(1, 1, 1);
                surfaceData.color = float3 (1, 1, 1);
            }

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"

            #pragma vertex Vert
            #pragma fragment Frag

            ENDHLSL
        }
    }
}
