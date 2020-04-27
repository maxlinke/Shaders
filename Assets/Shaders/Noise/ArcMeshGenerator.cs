using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArcMeshGenerator : MonoBehaviour {

    [Header("Generates a mesh for use with the arc shader. Won't be visible on its own as it will have zero thickness.")]
    [SerializeField, Range(3, 16)] int ringVertexCount;
    [SerializeField, Range(1, 100)] int singleGenSegmentCount;
    [SerializeField] Axis axis;
    [SerializeField] float length;
    [SerializeField] bool endCapCentersHaveNormals;
    [SerializeField] bool symmetric;
    [SerializeField] bool onlyGenerateDefault;
    [SerializeField] ArcMeshSettingsCollection[] groupedSettings;

    [System.Serializable] 
    struct ArcMeshSettingsCollection {
        [Tooltip("Just for humans. Doesn't actually do anything...")] public string name;       // HOLY FUCK THIS ACTUALLY NAMES THE ARRAY ELEMENT IN THE INSPECTOR!!!
        public bool excludeInMeshGeneration;
        [Range(1, 10)] public int occurences;
        public ArcMeshSettings[] settings;
    }

    [System.Serializable]
    struct ArcMeshSettings {
        [Tooltip("Just for humans. Doesn't actually do anything...")] public string name;
        [Range(1, 100)] public int segments;
        [Range(0, 1)] public float thickness;
        [Range(0, 5)] public float frequency;
        [Range(0, 1)] public float amplitude;
        [Range(0, 1)] public float noisiness;

        public static ArcMeshSettings Default { 
            get {
                var output = new ArcMeshSettings();
                output.segments = 10;
                output.thickness = 1f;
                output.frequency = 1f;
                output.amplitude = 1f;
                output.noisiness = 1f;
                return output;
            }
        }

    }

    enum Axis { X, Y, Z }

    void OnValidate () {
        for(int i=0; i<groupedSettings.Length; i++){
            if(groupedSettings[i].occurences < 1){
                groupedSettings[i].occurences = 1;
            }
            if(groupedSettings[i].settings == null){
                groupedSettings[i].settings = new ArcMeshSettings[0];
            }
            if(groupedSettings[i].settings.Length < 1){
                groupedSettings[i].settings = new ArcMeshSettings[1];
                groupedSettings[i].settings[0] = ArcMeshSettings.Default;
            }
        }
    }

    [ContextMenu("Regenerate Mesh")]
    public void RegenerateMesh () {
        var mf = GetComponent<MeshFilter>();
        if(mf == null){
            Debug.LogError("No Meshfilter on GameObject!");
            return;
        }
        try{
            Mesh newMesh;
            if(onlyGenerateDefault || groupedSettings == null || groupedSettings.Length < 1){
                var genSettings = ArcMeshSettings.Default;
                genSettings.segments = singleGenSegmentCount;
                newMesh = GenerateMesh(genSettings);
            }else{
                int maxOcc = 0;
                foreach(var group in groupedSettings){
                    if(group.excludeInMeshGeneration){
                        continue;
                    }
                    if(group.occurences > maxOcc){
                        maxOcc = group.occurences;
                    }
                }

                List<ArcMeshSettingsCollection> groupsToUse = new List<ArcMeshSettingsCollection>();
                for(int o=0; o<maxOcc; o++){
                    for(int i=0; i<groupedSettings.Length; i++){
                        if(groupedSettings[i].excludeInMeshGeneration){
                            continue;
                        }
                        int gOcc = groupedSettings[i].occurences;
                        int rOcc = maxOcc / gOcc;   // say there's max. 7 occurences and this group has 2
                        if(o % rOcc == 0){          // then this is true for 0 and 3 for this group and true everytime for the group with the max occurences
                            groupsToUse.Add(groupedSettings[i]);
                        }
                    }
                }
                
                List<CombineInstance> partialMeshes = new List<CombineInstance>();
                for(int i=0; i<groupsToUse.Count; i++){
                    float tOff = (float)i / groupsToUse.Count;
                    for(int j=0; j<groupsToUse[i].settings.Length; j++){
                        var newCI = new CombineInstance();
                        newCI.mesh = GenerateMesh(groupsToUse[i].settings[j], tOff);
                        partialMeshes.Add(newCI);
                    }
                }

                newMesh = new Mesh();
                newMesh.CombineMeshes(partialMeshes.ToArray(), true, false, false);
            }
            mf.sharedMesh = newMesh;
            if(mf.sharedMesh != null){
                Debug.Log("successfully generated new mesh! (" + mf.sharedMesh.vertices.Length + " vertices)");
            }else{
                Debug.LogWarning("set mesh NULL");
            }
        }catch(System.Exception e){
            Debug.LogError(e.ToString());
        }
    }

	Mesh GenerateMesh (ArcMeshSettings inputSettings, float timingOffset = 0) {
        int segmentCount = inputSettings.segments;
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
        Color[] colors = new Color[vertices.Length];
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
            // uvs[i] = new Vector2((a + (symmetric ? (length / 2f) : 0f)) / length, Mathf.Repeat(b / (2f * Mathf.PI), 1f));
            uvs[i] = new Vector2((a + (symmetric ? (length / 2f) : 0f)) / length, inputSettings.thickness);
        }
        // other information as vertex colors
        var colorInfo = new Color(inputSettings.frequency / 2f, inputSettings.amplitude, inputSettings.noisiness, timingOffset);
        for(int i=0; i<colors.Length; i++){
            colors[i] = colorInfo;
        }
        var output = new Mesh();
        output.vertices = vertices;
        output.normals = normals;
        output.uv = uvs;
        output.colors = colors;
        output.triangles = triangles;
        output.bounds = new Bounds((start + end) / 2f, Vector3.one * length);
        output.name = "Arc Mesh (" + output.GetHashCode() + ")";
        return output;
    }

}

