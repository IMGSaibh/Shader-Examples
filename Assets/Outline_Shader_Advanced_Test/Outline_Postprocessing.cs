using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace ScenarioArchitect
{
    public class Outline_Postprocessing : MonoBehaviour
    {

        Camera camSelectedObjects;
        public Shader outline_shader;
        public Shader masking_shader;
        Material postOutlineMat;
        public bool showMaskingTexture = false;
        public Color outlineColor;
        [Range(1.0f, 4.0f)]
        public float thickness = 1;

        [Range(0.01f, 1f)]
        public float opacity = 0.25f;


        void Start()
        {
            //attachedcamera = GetComponent(Camera);
            postOutlineMat = new Material(outline_shader);
            camSelectedObjects = new GameObject().AddComponent<Camera>();
            camSelectedObjects.depth = 0;

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
            camSelectedObjects.clearFlags = CameraClearFlags.SolidColor;

            //cull any layer except the outline
            //mask out other layers by masking with bitshift
            //ref:https://docs.unity3d.com/ScriptReference/Camera-cullingMask.html
            camSelectedObjects.cullingMask = 1 << LayerMask.NameToLayer("PostProcessing");

            //temporary rendertexture for selected objects
            RenderTexture tempRT = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.R8);
            tempRT.filterMode = FilterMode.Point;
            camSelectedObjects.targetTexture = tempRT;

            //render all objects with draw_Selected_Objects_shader.
            camSelectedObjects.RenderWithShader(masking_shader, "");

            postOutlineMat.SetFloat("_Thickness", thickness);
            postOutlineMat.SetFloat("_Opacity", opacity);
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

}
