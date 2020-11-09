using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenEffect_old_movie : MonoBehaviour
{

    public Shader oldFilmShader;
    public float oldFilmEffectAmount = 1.0f;

    public Color sepiaColor = Color.white;
    public Texture2D vignetteTexture;
    public float vignetteAmount = 1.0f;

    public Texture2D scratchesTexture;

    public float scratchesYSpeed = 10.0f;
    public float scratchesXSpeed = 10.0f;

    public Texture2D dustTexture;
    public float dustYSpeed = 10.0f;
    public float dustXSpeed = 10.0f;
    private Material curMaterial;
    private float randomValue;

    Material material
    {
        get
        {
            if (curMaterial == null)
            {
                curMaterial = new Material(oldFilmShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (oldFilmShader != null)
        {
            material.SetColor("_SepiaColor", sepiaColor);
            material.SetFloat("_VignetteAmount", vignetteAmount);
            material.SetFloat("_EffectAmount", oldFilmEffectAmount);


            if (vignetteTexture)
            {
                material.SetTexture("_VignetteTex", vignetteTexture);
            }
            if (scratchesTexture)
            {
                material.SetTexture("_ScratchesTex", scratchesTexture);
                material.SetFloat("_ScratchesYSpeed", scratchesYSpeed);
                material.SetFloat("_ScratchesXSpeed", scratchesXSpeed);
            }

            if (dustTexture)
            {
                material.SetTexture("_DustTex", dustTexture);
                material.SetFloat("_dustYSpeed", dustYSpeed);
                material.SetFloat("_dustXSpeed", dustXSpeed);
                material.SetFloat("_RandomValue", randomValue);
            }

            //render result
            Graphics.Blit(sourceTexture, destTexture, material);

        }
        else
        {
            //render result
            Graphics.Blit(sourceTexture, destTexture);
        }
    }

    void Update()
    {
        vignetteAmount = Mathf.Clamp01(vignetteAmount);
        oldFilmEffectAmount = Mathf.Clamp(oldFilmEffectAmount, 0f, 1.5f);
        randomValue = Random.Range(-1f, 1f);
    }

}
