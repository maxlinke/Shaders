using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AfterOpaqueImageEffect : MonoBehaviour {

	[SerializeField] Material effectMaterial;

	[ImageEffectOpaque]
	void OnRenderImage(RenderTexture src, RenderTexture dst){
		Graphics.Blit(src, dst, effectMaterial);
	}

}
