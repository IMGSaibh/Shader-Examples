using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffectOutlineShader : MonoBehaviour
{
    Camera camSelectedObjects;
    public Shader post_outline_shader;
    public Shader draw_Selected_Objects_shader;
    Material postOutlineMat;
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
        //set up a temporary camera
        camSelectedObjects.CopyFrom(Camera.main);
        camSelectedObjects.backgroundColor = Color.black;
        camSelectedObjects.clearFlags = CameraClearFlags.Color;

        //cull any layer that isn't the outline
        camSelectedObjects.cullingMask = 1 << LayerMask.NameToLayer("Outline");

        //make the temporary rendertexture
        RenderTexture tempRT = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.R8);


        //put it to video memory
        //TempRT.Create();

        //set the camera's target texture when rendering
        camSelectedObjects.targetTexture = tempRT;

        //render all objects this camera can render, but with our custom shader.
        camSelectedObjects.RenderWithShader(draw_Selected_Objects_shader, "");

        postOutlineMat.SetTexture("_SceneTex", source);

        //copy the temporary RT to the final image
        Graphics.Blit(tempRT, destination, postOutlineMat);

        RenderTexture.ReleaseTemporary(tempRT);
        //release the temporary RT
        //tempRT.Release();
    }
}
