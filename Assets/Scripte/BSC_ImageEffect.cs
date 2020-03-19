using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BSC_ImageEffect : MonoBehaviour
{
    public Shader curShader;

    public float brightnessAmount = 1.0f;
    public float saturationAmount = 1.0f;
    public float contrastAmount = 1.0f;
    //Material for access the Properties of Shader
    private Material curMaterial;

    Material material
    {
        get
        {
            if (curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }

    void Start()
    {
        //check if shader is assigned and supported
        if (!curShader && !curShader.isSupported)
            enabled = false;


    }

    private void Update()
    {
        brightnessAmount = Mathf.Clamp(brightnessAmount, 0.0f, 2.0f);
        saturationAmount = Mathf.Clamp(saturationAmount, 0.0f, 2.0f);
        contrastAmount = Mathf.Clamp(contrastAmount, 0.0f, 3.0f);

        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (curShader != null)
        {
            material.SetFloat("_BrighnessAmount", brightnessAmount);
            material.SetFloat("_satAmount", saturationAmount);
            material.SetFloat("_conAmount", contrastAmount);

            //Copy source Texture into Destiniation Texture
            //apply shader and material to source
            //
            Graphics.Blit(source, destination, curMaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}
