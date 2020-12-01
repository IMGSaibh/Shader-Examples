using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

//https://docs.unity3d.com/Packages/com.unity.postprocessing@2.1/manual/Writing-Custom-Effects.html
//https://learn.unity.com/tutorial/creating-a-custom-post-processing-effect-for-lwrp#5e4569dbedbc2a09c4baf37a

[Serializable]
[PostProcess(typeof(SCA_Outline), PostProcessEvent.AfterStack, "Scenario Architect/Outline")]
public sealed class SCA_Outline : PostProcessEffectSettings
{
    [Range(0f, 4f), Tooltip("Outline effect thickness.")]
    public FloatParameter thickness = new FloatParameter { value = 1.0f };

    public override bool IsEnabledAndSupported(PostProcessRenderContext context)
    {
        return enabled.value && thickness.value > 0f;
    }
}


public sealed class SCA_Outline_Renderer : PostProcessEffectRenderer<SCA_Outline>
{
    //private static int _SceneTextureID = Shader.PropertyToID("_SceneTex");

    public override void Render(PostProcessRenderContext context)
    {

        //Texture outlineTexture = Shader.GetGlobalTexture(_SceneTextureID);



        Camera camSelectedObjects = new Camera();
        camSelectedObjects.CopyFrom(Camera.main);
        camSelectedObjects.depth = 0;
        camSelectedObjects.backgroundColor = Color.black;
        camSelectedObjects.clearFlags = CameraClearFlags.SolidColor;



        camSelectedObjects.cullingMask = 1 << LayerMask.NameToLayer("PostProcessing");

        //temporary rendertexture for selected objects
        RenderTexture tempRT = RenderTexture.GetTemporary(context.camera.activeTexture.width, context.camera.activeTexture.height, 0, RenderTextureFormat.R8);
        tempRT.filterMode = FilterMode.Point;
        camSelectedObjects.targetTexture = tempRT;

        PropertySheet sheet = context.propertySheets.Get(Shader.Find("Hidden/Scenario Architect/Outline"));
        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetTexture("_SceneTex", context.camera.activeTexture);



        //command buffer provided by context
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);


    }



  
}
