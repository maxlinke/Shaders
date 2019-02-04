using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSetter : MonoBehaviour {

	[SerializeField] Material matA;
	[SerializeField] Material matB;
	[SerializeField] GameObject parentA;
	[SerializeField] GameObject parentB;

	[ContextMenu("Set Materials")]
	public void SetMaterials () {
		MeshRenderer[] meshRenderersA = parentA.GetComponentsInChildren<MeshRenderer>();
		for(int i=0; i<meshRenderersA.Length; i++){
			meshRenderersA[i].material = matA;
		}
		MeshRenderer[] meshRenderersB = parentB.GetComponentsInChildren<MeshRenderer>();
		for(int i=0; i<meshRenderersB.Length; i++){
			meshRenderersB[i].material = matB;
		}
	}

}