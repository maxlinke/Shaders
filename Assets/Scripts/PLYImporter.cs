using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

public class PLYImporter : MonoBehaviour {

	//TODO throw some descriptive exceptions when things go wrong (e.g. not even a .ply-file etc)

	static string[] dataTypes = new string[]{
		"char", "uchar", "short", "ushort", "int", "uint", "float", "double", "list"
	};

	[Tooltip("e.g. \"StreamingAssets/Model.ply\"")]
	[SerializeField] string filePath;

	[SerializeField] MeshFilter mf;
	[SerializeField] bool loadOnStart = false;

	[Tooltip("Export with Z Forward and Y Up")]
	[SerializeField] bool blenderFix = true;

	void Start () {
		if(loadOnStart) LoadModel();
	}

	public void LoadModel () {
		mf.sharedMesh = GetMeshFromFile(filePath, blenderFix);
	}

//	string FileToString (string filePath) {
//		string stringified = "";
//		StreamReader inputStream = new StreamReader(Application.dataPath + "/" + filePath);
//		while(!inputStream.EndOfStream){
//			stringified += inputStream.ReadLine() + "\n";
//		}
//		inputStream.Close();
//		return stringified;
//	}

	public static Mesh GetMeshFromFile (string filePath, bool blenderFix = false) {
		Vector3[] vertices, normals;
		Color32[] colors32;
		Vector2[] uv;
		int[] triangles;
		Dictionary<string, int> propertyIndices;
		StreamReader inputStream = new StreamReader(Application.dataPath + "/" + filePath);
		ReadHeader(inputStream, out vertices, out normals, out colors32, out uv, out triangles, out propertyIndices);
		ReadData(inputStream, ref vertices, ref normals, ref colors32, ref uv, ref triangles, propertyIndices);
		inputStream.Close();
		Mesh output = CreateMesh(vertices, normals, colors32, uv, triangles, blenderFix);
		string[] splitPath = filePath.Split('/');
		string fileName = splitPath[splitPath.Length - 1].Split('.')[0];
		output.name = fileName;

		return output;
	}

	static void ReadHeader (StreamReader inputStream, out Vector3[] vertices, out Vector3[] normals, out Color32[] colors32, out Vector2[] uv, out int[] triangles, out Dictionary<string, int> propertyIndices) {
		propertyIndices = new Dictionary<string, int>();
		int numberOfVertices = 0;	
		int numberOfFaces = 0;
		int propertyCounter = 0;
		string line;
		inputStream.ReadLine();				//ply (should check but i'll pass...)
		inputStream.ReadLine();				//format (e.g. ascii 1.0)
		while(!(line = inputStream.ReadLine()).Contains("end_header")){
			if(line.StartsWith("comment")){
				LogComment(line);
			}else{
				if(line.StartsWith("element")){							//element type and number thereof (e.g. "element vertex 16")
					ReadElement(line, ref numberOfVertices, ref numberOfFaces);
					propertyCounter = 0;	//reset propertycounter
				}else if(line.StartsWith("property")){						//property type (e.g. "float nx" or "uchar green")
					line = line.Remove(0, "property".Length + 1);
					if(TryRemoveDataType(ref line)){
						propertyIndices.Add(line, propertyCounter);
					}else{
						Debug.LogWarning("Property + \"" + line + "\" is of no use to the importer");
					}
					propertyCounter++;
				}else{

				}
			}
		}
		vertices = new Vector3[numberOfVertices];
		normals = new Vector3[numberOfVertices];
		colors32 = new Color32[numberOfVertices];
		uv = new Vector2[numberOfVertices];
		triangles = new int[3 * numberOfFaces];
	}

	static void ReadData (StreamReader inputStream, ref Vector3[] vertices, ref Vector3[] normals, ref Color32[] colors32, ref Vector2[] uv, ref int[] triangles, Dictionary<string, int> propertyIndices) {
		int vertCounter = 0;
		int faceCounter = 0;
		while(!inputStream.EndOfStream){
			string line = inputStream.ReadLine();
			if(line.StartsWith("comment")){								//log comments to console. might be useful. or not.
				LogComment(line);
			}else{
				if(vertCounter < vertices.Length){
					VertexData data = ReadVertexDataFromLine(line, propertyIndices);
					vertices[vertCounter] = new Vector3(data.x, data.y, data.z);
					normals[vertCounter] = new Vector3(data.nx, data.ny, data.nz);
					colors32[vertCounter] = new Color32(data.r, data.g, data.b, (byte)255);
					uv[vertCounter] = new Vector2(data.u, data.v);
					vertCounter++;
				}else{
					string[] split = line.Split(' ');
					int numberOfVertsPerFace = int.Parse(split[0]);
					if(numberOfVertsPerFace != 3) throw new UnityException("The importer isn't built to handle faces with " + numberOfVertsPerFace + " vertices (only triangles are allowed)");
					for(int i=1; i<=3; i++){
						triangles[(3 * faceCounter) + i - 1] = int.Parse(split[i]);
					}
					faceCounter++;
				}
			}
		}
	}

	static Mesh CreateMesh (Vector3[] vertices, Vector3[] normals, Color32[] colors32, Vector2[] uv, int[] triangles, bool flipZ = false) {
		Mesh output = new Mesh();
		if(flipZ){
			Vector3 scale = new Vector3(1, 1, -1);
			for(int i=0; i<vertices.Length; i++){
				vertices[i] = Vector3.Scale(vertices[i], scale);
				normals[i] = Vector3.Scale(normals[i], scale);
			}
			for(int i=0; i<triangles.Length; i+=3){
				int temp = triangles[i+1];
				triangles[i+1] = triangles[i+2];
				triangles[i+2] = temp;
			}
		}
		output.vertices = vertices;
		output.normals = normals;
		output.colors32 = colors32;
		output.uv = uv;
		output.triangles = triangles;
		return output;
	}

	static VertexData ReadVertexDataFromLine (string line, Dictionary<string, int> propertyIndices) {
		string[] split = line.Split(' ');
		VertexData output = new VertexData();
		output.SetRGBMax();
		int index;
		if(propertyIndices.TryGetValue("x", out index)) output.x = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("y", out index)) output.y = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("z", out index)) output.z = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("nx", out index)) output.nx = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("ny", out index)) output.ny = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("nz", out index)) output.nz = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("s", out index)) output.u = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("t", out index)) output.v = float.Parse(split[index]);
		if(propertyIndices.TryGetValue("red", out index)) output.r = (byte)(int.Parse(split[index]));
		if(propertyIndices.TryGetValue("green", out index)) output.g = (byte)(int.Parse(split[index]));
		if(propertyIndices.TryGetValue("blue", out index)) output.b = (byte)(int.Parse(split[index]));
		return output;
	}

	static bool TryRemoveDataType (ref string line) {
		for(int i=0; i<dataTypes.Length; i++){
			if(line.StartsWith(dataTypes[i])){
				line = line.Remove(0, dataTypes[i].Length + 1);
				return true;
			}
		}
		Debug.LogWarning("didn't remove datatype from line \"" + line + "\"");
		return false;
	}

	static void LogComment (string line) {
		line = line.Remove(0, "comment".Length + 1);
		Debug.Log("File comment \"" + line + "\"");
	}

	static void ReadElement (string line, ref int numberOfVertices, ref int numberOfFaces) {
		line = line.Remove(0, "element".Length + 1);
		if(line.StartsWith("vertex")){
			line = line.Remove(0, "vertex".Length + 1);
			numberOfVertices = int.Parse(line);
		}else if(line.StartsWith("face")){
			line = line.Remove(0, "face".Length + 1);
			numberOfFaces = int.Parse(line);
		}else{
			Debug.LogWarning("Unknown element type \"" + line + "\"");
		}
	}

	struct VertexData {

		public float x, y, z, nx, ny, nz, u, v;
		public byte r, g, b;

		public void SetRGBMax () {
			r = g = b = 255;
		}

	}

}
