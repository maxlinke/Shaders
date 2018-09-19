using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PLYImporter))]
public class PLYImporterEditor : Editor {

	public override void OnInspectorGUI () {
		PLYImporter plyi = target as PLYImporter;
		DrawDefaultInspector();
		if(GUILayout.Button("Load Model")) plyi.LoadModel();
	}
}
