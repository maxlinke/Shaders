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
    [SerializeField] bool symmetric;

    enum Axis { X, Y, Z }

    [SerializeField] Vector2 atan2Input;
    [ContextMenu("ATAN2")]
    public void Atan2Test () {
        Debug.Log(Mathf.Atan2(atan2Input.x, atan2Input.y).ToString());
    }

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
                    ringNormals[i] = new Vector3(b, 0, a);
                    break;
                case Axis.Z:
                    ringNormals[i] = new Vector3(a, b, 0);
                    break;
                default:
                    throw new System.Exception("Invalid Axis \"" + axis.ToString() + "\"!");
            }
        }
        // first two vertices are end cap centers, then following are the segment rings
        Vector3[] vertices = new Vector3[((segmentCount + 1) * ringVertexCount) + 2];
        Vector3[] normals = new Vector3[vertices.Length];
        Vector2[] uvs = new Vector2[vertices.Length];
        Vector3 dir = (axis == Axis.X ? Vector3.right : axis == Axis.Y ? Vector3.up : Vector3.forward);
        Vector3 start, end;
        if(!symmetric){
            start = Vector3.zero;
            end = length * dir;
        }else{
            end = (length / 2) * dir;
            start = -end;
        }
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
        int[] triangles = new int[3 * ((2 * ringVertexCount * segmentCount) + (2 * ringVertexCount))];
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
        // generate the segments
        v = 2 * 3 * ringVertexCount;
        for(int i=0; i<segmentCount; i++){
            for(int j=0; j<ringVertexCount; j++){
                int a = 2 + (i * ringVertexCount) + j;
                int b = 2 + ((i+1) * ringVertexCount) + j;
                int c = 2 + ((i+1) * ringVertexCount) + ((j+1) % ringVertexCount);
                int d = 2 + (i * ringVertexCount) + ((j+1) % ringVertexCount);
                triangles[v++] = a;
                triangles[v++] = b;
                triangles[v++] = c;
                triangles[v++] = a;
                triangles[v++] = c;
                triangles[v++] = d;
            }
        }
        // set uvs
        for(int i=0; i<uvs.Length; i++){
            float a, b;
            switch(axis){
                case Axis.X:
                    a = vertices[i].x;
                    b = Mathf.Atan2(normals[i].y, normals[i].z);
                    break;
                case Axis.Y:
                    a = vertices[i].y;
                    b = Mathf.Atan2(normals[i].z, normals[i].x);
                    break;
                case Axis.Z:
                    a = vertices[i].z;
                    b = Mathf.Atan2(normals[i].x, normals[i].y);
                    break;
                default:
                    throw new System.Exception("Invalid Axis \"" + axis.ToString() + "\"!");
            }
            uvs[i] = new Vector2((a + (symmetric ? (length / 2f) : 0f)) / length, Mathf.Repeat(b / (2f * Mathf.PI), 1f));
        }
        var output = new Mesh();
        output.vertices = vertices;
        output.normals = normals;
        output.uv = uvs;
        output.triangles = triangles;
        output.bounds = new Bounds((start + end) / 2f, Vector3.one * length);
        return output;
    }

}

