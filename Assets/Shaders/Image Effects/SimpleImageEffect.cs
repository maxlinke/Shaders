using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SimpleImageEffect : MonoBehaviour {

	[SerializeField] bool directlyToScreen;
	[SerializeField] Material effectMaterial;

	void OnRenderImage(RenderTexture src, RenderTexture dst){
        if(effectMaterial == null){
            Graphics.Blit(src, dst);
        }else{
		    Graphics.Blit(src, (directlyToScreen ? null : dst), effectMaterial);
        }
	}

}
