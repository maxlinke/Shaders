using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FogImageEffect : MonoBehaviour {

    [SerializeField] Shader fogEffectShader;

    Camera cam;
    Material fogEffectMaterial;

    [ContextMenu("Log rendering paths")]
    void LogRenderingPaths () {
        Debug.Log("Set: " + cam.renderingPath.ToString() + "\nActual: " + cam.actualRenderingPath.ToString());
    }

    void Reset () {
        cam = GetComponent<Camera>();
        fogEffectShader = null;
        fogEffectMaterial = null;
    }

    void OnValidate () {
        cam = null;
        fogEffectMaterial = null;
    }

    [ImageEffectOpaque]
    void OnRenderImage (RenderTexture src, RenderTexture dst) {
        if(cam == null){
            cam = GetComponent<Camera>();
        }
        if(fogEffectMaterial == null && fogEffectShader != null){
            fogEffectMaterial = new Material(fogEffectShader);
        }
        if(fogEffectMaterial == null || cam.actualRenderingPath != RenderingPath.DeferredShading){      // don't need to nullcheck cam because onrenderimage wouldn't be called otherwise
            Graphics.Blit(src, dst);
        }else{
            if(cam.depthTextureMode == DepthTextureMode.None){
                cam.depthTextureMode = DepthTextureMode.Depth;
            }
            Graphics.Blit(src, dst, fogEffectMaterial);
        }
    }

}
