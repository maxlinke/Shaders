using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDepthTextureEnabler : MonoBehaviour {

	[SerializeField] Camera cam;

	void OnEnable () {
		cam.depthTextureMode = DepthTextureMode.Depth;
	}
}
