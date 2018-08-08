using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SimpleImageEffect : MonoBehaviour {

	[SerializeField] bool directlyToScreen;
	[SerializeField] Material effectMaterial;

	void OnRenderImage(RenderTexture src, RenderTexture dst){
		Graphics.Blit(src, (directlyToScreen ? null : dst), effectMaterial);
	}

}
