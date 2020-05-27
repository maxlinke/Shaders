using UnityEngine;

public class RuntimeSkyboxLerper : MonoBehaviour {

    [Range(0, 1)] public float lerpAmount;

    int lerpPropID;
    Material skyboxMat;

	void Awake () {
        lerpPropID = Shader.PropertyToID("_LerpAmount");
        if(RenderSettings.skybox.HasProperty(lerpPropID)){
		    skyboxMat = Instantiate(RenderSettings.skybox);
            RenderSettings.skybox = skyboxMat;
        }else{
            skyboxMat = null;
            Debug.LogError("Skybox Material doesn't seem to be lerpable!");
        }
	}
	
	void Update () {
        if(skyboxMat == null){
            return;
        }
		if(skyboxMat.GetFloat(lerpPropID) != lerpAmount){
            skyboxMat.SetFloat(lerpPropID, lerpAmount);
            DynamicGI.UpdateEnvironment();
        }
	}
}
