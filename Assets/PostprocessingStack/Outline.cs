using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


[Serializable]
[PostProcess(typeof(Outline), PostProcessEvent.AfterStack, "Custom/Outline")]
public sealed class Outline : PostProcessEffectSettings
{
    [Range(0f, 4f), Tooltip("Grayscale effect intensity.")]
    public FloatParameter thickness = new FloatParameter { value = 0.5f };
    [Range(0f, 1f), Tooltip("Grayscale effect intensity.")]
    public FloatParameter opacity = new FloatParameter { value = 0.5f };

    public TextureParameter sceneText = new TextureParameter { value = null };
}

public sealed class OutlineRenderer : PostProcessEffectRenderer<Outline>
{
    public override void Render(PostProcessRenderContext context)
    {

        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Outline_Blur_HLSL"));

        sheet.properties.SetTexture("_SceneTex", settings.sceneText);
        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_Opacity", settings.opacity);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
