﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraOutlineShaderAdvanced_3 : MonoBehaviour
{
    Camera camSelectedObjects;
    public Shader post_outline_shader;
    public Shader masking_outline_shader;
    Material postOutlineMat;
    public bool showMaskingTexture = false;
    public Color outlineColor;
    [Range(1.0f, 3.0f)]
    public float distance = 1;

    void Start()
    {
        //attachedcamera = GetComponent(Camera);
        postOutlineMat = new Material(post_outline_shader);
        camSelectedObjects = new GameObject().AddComponent<Camera>();

    }

    /// <summary>
    /// stores a rendered scene into source texture
    /// </summary>
    /// <param name="source"></param>
    /// <param name="destination"></param>
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //set up a second camera for rendering selected objects
        camSelectedObjects.CopyFrom(Camera.main);
        camSelectedObjects.backgroundColor = Color.black;
        camSelectedObjects.clearFlags = CameraClearFlags.Color;

        //cull any layer except the outline
        //mask out other layers by masking with bitshift
        //ref:https://docs.unity3d.com/ScriptReference/Camera-cullingMask.html
        camSelectedObjects.cullingMask = 1 << LayerMask.NameToLayer("Outline");

        //temporary rendertexture for selected objects
        RenderTexture tempRT = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.R8);
        camSelectedObjects.targetTexture = tempRT;

        //render all objects with draw_Selected_Objects_shader.
        camSelectedObjects.RenderWithShader(masking_outline_shader, "");

        postOutlineMat.SetFloat("_Distance", distance);
        postOutlineMat.SetColor("_OutlineColor", outlineColor);
        postOutlineMat.SetTexture("_SceneTex", source);
        //_SceneTex
        //copy the temporary RT to the final image
        if (showMaskingTexture)
        {
            Graphics.Blit(tempRT, destination);
        }
        else
            Graphics.Blit(tempRT, destination, postOutlineMat);

        RenderTexture.ReleaseTemporary(tempRT);

    }
}
