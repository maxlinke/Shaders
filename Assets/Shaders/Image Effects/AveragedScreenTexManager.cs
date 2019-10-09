using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AveragedScreenTexManager : MonoBehaviour {

    [SerializeField] float updateInterval;
    [SerializeField] Material blurMat;  //material because it gets a few properties of its own. instead of requiring this class to know the specifics of the shader...

    float lastUpdate;
    RenderTexture tempTex;
    RenderTexture blurTex;
    int texID;

    //maybe the averaging is overkill and i only need to keep track of the last one? idk... since the stuff that matters will be reading itself basically
    //and together with the flow there has to be blurring

    void Awake () {
        lastUpdate = 0f;
        tempTex = new RenderTexture(Screen.width, Screen.height, 24);
        blurTex = new RenderTexture(Screen.width, Screen.height, 24);
        texID = Shader.PropertyToID("_AveragedScreenTex");
    }

    void OnRenderImage (RenderTexture src, RenderTexture dst) {
        if(Time.time - lastUpdate > updateInterval){
            Graphics.Blit(src, tempTex, blurMat);  //can't blit directly to blurTex because that will clear blurtex before doing the blitting...
            Graphics.Blit(tempTex, blurTex);
            lastUpdate = Time.time;
            Shader.SetGlobalTexture(texID, blurTex);
        }
        Graphics.Blit(src, dst);
    }
}
