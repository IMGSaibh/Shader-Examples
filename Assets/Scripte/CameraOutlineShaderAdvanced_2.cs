using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraOutlineShaderAdvanced_2 : MonoBehaviour
{

    //For Antialaising in Texture draw before post processing 
    const CameraEvent cameraEvent = CameraEvent.AfterForwardAlpha;
    CommandBuffer commandBuffer;

    public Camera mainCamera;
    public Material maskingShaderMaterial;
    public Material outlineShaderMaterial;

    public List<Renderer> objectRenderer = new List<Renderer>();

    [Range(1, 30)]
    public float thickness = 1;
    public Color color;

    private int outlineTextureID;
    private int outlineSizeID;
    private int outlineColorID;

    public bool showMaskingTexture;


    private void OnEnable()
    {

        outlineTextureID = Shader.PropertyToID("_HighlightTexture");
        outlineSizeID = Shader.PropertyToID("_Size");
        outlineColorID = Shader.PropertyToID("_ColorMain");
        BuildComandBuffer();

    }


    private void OnDisable()
    {
        if (mainCamera != null && commandBuffer != null)
        {
            mainCamera.RemoveCommandBuffer(cameraEvent, commandBuffer);
            commandBuffer = null;
        }
    }

    private void BuildComandBuffer()
    {
        if (mainCamera == null)
        {
            return;
        }

        if (commandBuffer == null)
        {
            commandBuffer = new CommandBuffer();
            commandBuffer.name = "Postprocessing";
            mainCamera.AddCommandBuffer(cameraEvent, commandBuffer);
        }
        commandBuffer.Clear();

        // Can't do shit without these
        if (maskingShaderMaterial == null || outlineShaderMaterial == null)
        {
            Debug.LogError("No Material is set");
            return;

        }

        commandBuffer.GetTemporaryRT(outlineTextureID, mainCamera.pixelWidth, mainCamera.pixelHeight, 24, FilterMode.Point, RenderTextureFormat.R8);
        commandBuffer.SetRenderTarget(outlineTextureID);
        commandBuffer.ClearRenderTarget(true, true, Color.black);

        foreach (Renderer render in objectRenderer)
        {
            if (!render)
                continue;

            commandBuffer.DrawRenderer(render, maskingShaderMaterial);
        }

        //Draw image effect
        commandBuffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        commandBuffer.Blit(outlineTextureID, BuiltinRenderTextureType.CameraTarget, showMaskingTexture ? null : outlineShaderMaterial);
        commandBuffer.ReleaseTemporaryRT(outlineTextureID);

        outlineShaderMaterial.SetFloat(outlineSizeID, thickness);
        outlineShaderMaterial.SetColor(outlineColorID, color);

    }
    public void ReleaseAll()
    {
        if (mainCamera != null && commandBuffer != null)
        {
            mainCamera.RemoveCommandBuffer(cameraEvent, commandBuffer);
            commandBuffer = null;
        }
    }
    private void OnValidate()
    {
        if (mainCamera == null)
        {
            mainCamera = GetComponent<Camera>();
        }

        if (mainCamera != null && mainCamera.depthTextureMode == DepthTextureMode.None)
        {
            mainCamera.depthTextureMode = DepthTextureMode.Depth;
        }
        //ReleaseAll();

        BuildComandBuffer();
    }

}
