using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseDataToShader : MonoBehaviour
{

    Plane plane = new Plane(Vector3.up, Vector3.zero);
    Vector2 mousePos;
    Ray ray;
    Vector3 worldMousePos;
    // Update is called once per frame
    private void Start()
    {
        Shader.SetGlobalVector("_MousePos", mousePos);
    }


    private void Update()
    {
        mousePos = Input.mousePosition;
        ray = GetComponent<Camera>().ScreenPointToRay(mousePos);
        if (plane.Raycast(ray, out float enterDist))
        {
            worldMousePos = ray.GetPoint(enterDist);
        }

    }
}
