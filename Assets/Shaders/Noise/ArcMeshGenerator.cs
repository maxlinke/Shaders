using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArcMeshGenerator : MonoBehaviour {

    [Header("Generates a mesh for use with the arc shader. Won't be visible on its own as it will have zero thickness.")]
    [SerializeField, Range(3, 16)] int ringVertexCount;
    [SerializeField, Range(1, 100)] int segmentCount;
    [SerializeField] Axis axis;
    [SerializeField] float length;
    [SerializeField] bool endCapCentersHaveNormals;

    enum Axis { X, Y, Z }

    [ContextMenu("Regenerate Mesh")]
    public void RegenerateMesh () {
        var mf = GetComponent<MeshFilter>();
        if(mf == null){
            Debug.LogError("No Meshfilter on GameObject!");
            return;
        }
        try{
            mf.sharedMesh = GenerateMesh();
            
        }catch(System.Exception e){
            Debug.LogError(e.ToString());
        }
    }

	Mesh GenerateMesh () {
        Vector3[] ringNormals = new Vector3[ringVertexCount];
        for(int i=0; i<ringVertexCount; i++){
            float frac = (float)i / ringVertexCount;
            float a = Mathf.Sin(2f * Mathf.PI * frac);
            float b = Mathf.Cos(2f * Mathf.PI * frac);
            switch(axis){
                case Axis.X:
                    ringNormals[i] = new Vector3(0, a, b);
                    break;
                case Axis.Y:
                    ringNormals[i] = new Vector3(a, 0, b);
                    break;
                case Axis.Z:
                    ringNormals[i] = new Vector3(a, b, 0);
                    break;
                default:
                    throw new System.Exception("Invalid Axis \"" + axis.ToString() + "\"!");
            }
        }
        Vector3[] vertices = new Vector3[((segmentCount + 1) * ringVertexCount) + 2];
        Vector3[] normals = new Vector3[vertices.Length];
        Vector3 start = Vector3.zero;
        Vector3 end = length * (axis == Axis.X ? Vector3.right : axis == Axis.Y ? Vector3.up : Vector3.forward);
        vertices[0] = start;
        normals[0] = (start - end).normalized * (endCapCentersHaveNormals ? 1f : 0f);
        vertices[1] = end;
        normals[1] = (end - start).normalized * (endCapCentersHaveNormals ? 1f : 0f);
        int v = 2;
        for(int l=0; l<=segmentCount; l++){
            Vector3 p = Vector3.Lerp(start, end, (float)l / segmentCount);
            for(int r=0; r<ringVertexCount; r++){
                vertices[v] = p;
                normals[v] = ringNormals[r];
                v++;
            }
        }
        // int[] triangles = new int[3 * ((2 * ringVertexCount * segmentCount) + (2 * ringVertexCount))];
        int[] triangles = new int[3 * 2 * ringVertexCount];
        // generate end caps
        for(int i=0; i<ringVertexCount; i++){
            int fc = 3 * i;                     // front cap
            triangles[fc] = 0;
            triangles[fc+1] = 2 + i;
            triangles[fc+2] = 2 + ((i + 1) % ringVertexCount);
            int bc = fc + 3 * ringVertexCount;  // back cap
            triangles[bc] = 1;
            triangles[bc+1] = vertices.Length - 1 - i;
            triangles[bc+2] = vertices.Length - 1 - ((i + 1) % ringVertexCount);
        }
        
        var output = new Mesh();
        output.vertices = vertices;
        output.normals = normals;
        output.triangles = triangles;
        output.bounds = new Bounds((start + end) / 2f, Vector3.one * length);
        return output;
    }

}

