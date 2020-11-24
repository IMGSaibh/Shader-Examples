using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDepthtextureShader : MonoBehaviour
{
    public Shader depthtextureShader;
    Material depthtextureMaterial;
    [Range(0.0f, 1.0f)]
    public float depthPower = 1.0f; 
    void Start()
    {
        //check if shader is assigned and supported
        if (!depthtextureShader && !depthtextureShader.isSupported) 
        {
            Debug.Log("Shader not assigned or not supported");
            enabled = false;
        }

        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        Debug.Log("Camera depthTextureMode: " + Camera.main.depthTextureMode);
        depthtextureMaterial = new Material(depthtextureShader);


    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        if (depthtextureShader != null)
        {
            depthtextureMaterial.SetFloat("_DepthPower", depthPower);
            Graphics.Blit(source, destination, depthtextureMaterial);

        }
        else
        {
            Graphics.Blit(source, destination);

        }
    }

    // Update is called once per frame
    void Update()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        depthPower = Mathf.Clamp(depthPower, 0, 5);
    }

    private void OnDisable()
    {
        if (depthtextureMaterial)
        {
            DestroyImmediate(depthtextureMaterial);
        }
    }
}
