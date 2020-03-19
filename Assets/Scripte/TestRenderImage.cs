using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Render Texture needed for rendering Image Effects
//https://docs.unity3d.com/Manual/class-RenderTexture.html


[ExecuteInEditMode]
public class TestRenderImage : MonoBehaviour
{
    public Shader curShader;
    public float grayScaleAmount = 0.0f;
    public float depthPower = 1.0f;
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
        grayScaleAmount = Mathf.Clamp(grayScaleAmount, 0.0f, 1.0f);

        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        depthPower = Mathf.Clamp(depthPower, 0, 5);
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (curShader != null && curShader.name == "Custom/ImageEffect")
        {
            material.SetFloat("_LuminosityAmount", grayScaleAmount);

            //Copy source Texture into Destiniation Texture
            Graphics.Blit(source, destination, curMaterial);
        }
        else if (curShader != null && curShader.name == "Custom/Scene_Depth_Effect")
        {
            material.SetFloat("_DepthPower", depthPower);
            //Copy source Texture into Destiniation Texture
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
