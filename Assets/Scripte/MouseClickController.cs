using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseClickController : MonoBehaviour
{
	private Vector3 screenPosition;
	private Vector3 offset;

	private bool isMouseDrag;
	public GameObject target;


	// Update is called once per frame
	void Update()
	{
       
		if (Input.GetMouseButtonDown(0))
		{
			RaycastHit hitInfo;
			target = ReturnClickedObject(out hitInfo);

			if (target != null)
			{
				isMouseDrag = true;
				//Convert world position to screen position.
				screenPosition = Camera.main.WorldToScreenPoint(target.transform.position);
				offset = target.transform.position - Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, screenPosition.z));

                if (target.transform.childCount > 0)
                    foreach (Transform child in target.transform)
						child.gameObject.layer = LayerMask.NameToLayer("PostProcessing");

				else
					target.layer = LayerMask.NameToLayer("PostProcessing");

			}


		}

		if (Input.GetMouseButtonUp(0))
			isMouseDrag = false;

		if (isMouseDrag)
		{
			//track mouse position.
			Vector3 currentScreenSpace = new Vector3(Input.mousePosition.x, Input.mousePosition.y, screenPosition.z);
			//convert screen position to world position with offset changes.
			Vector3 currentPosition = Camera.main.ScreenToWorldPoint(currentScreenSpace) + offset;
			//It will update target gameobject's current postion.
			target.transform.position = currentPosition;
		}

	}

   

	// It will ray cast to mousepostion and return any hit objet.
	GameObject ReturnClickedObject(out RaycastHit hit)
	{
        if (target != null) 
		{
			if (target.transform.childCount > 0)
				foreach (Transform child in target.transform)
					child.gameObject.layer = LayerMask.NameToLayer("Default");
			else
				target.layer = LayerMask.NameToLayer("Default");
		}
        
		//GameObject target = null;
		Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

		if (Physics.Raycast(ray.origin, ray.direction * 10, out hit))
			target = hit.collider.gameObject;

		return target;
	}

}
