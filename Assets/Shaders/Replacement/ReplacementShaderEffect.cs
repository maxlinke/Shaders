using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour {

	[SerializeField] Camera cam;
	[SerializeField] Shader replacementShader;
	[SerializeField] string replacementTag;

	void Reset () {
		cam = GetComponent<Camera>();
	}

	void OnEnable () {
		cam.SetReplacementShader(replacementShader, replacementTag);
	}

	void OnDisable () {
		cam.ResetReplacementShader();
	}

}
