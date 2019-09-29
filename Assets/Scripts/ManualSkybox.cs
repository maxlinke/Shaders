using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ManualSkybox : MonoBehaviour {

	void OnWillRenderObject () {
        transform.position = Camera.current.transform.position;
        transform.localScale = Vector3.one * Camera.current.farClipPlane;
    }

}
