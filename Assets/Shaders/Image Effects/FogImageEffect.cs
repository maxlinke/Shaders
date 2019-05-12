using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FogImageEffect : MonoBehaviour {

    [SerializeField] Camera cam;
    [SerializeField] Shader fogEffect;

    Material fogEffectMaterial;

    [ContextMenu("Log rendering paths")]
    void LogRendeingPaths () {
        Debug.Log("Set: " + cam.renderingPath.ToString() + "\nActual: " + cam.actualRenderingPath.ToString());
    }

    void Reset () {
        cam = GetComponent<Camera>();
    }

    [ImageEffectOpaque]
    void OnRenderImage (RenderTexture src, RenderTexture dst) {
        if(fogEffectMaterial == null){
            fogEffectMaterial = new Material(fogEffect);
        }
        var renderPath = cam.actualRenderingPath;
        if(renderPath != RenderingPath.DeferredShading){
            Debug.LogWarning("This effect is meant to apply fog when using deferred shading. Currently using " + renderPath.ToString() + "!");
            Graphics.Blit(src, dst);
        }else{
            if(cam.depthTextureMode == DepthTextureMode.None){
                cam.depthTextureMode = DepthTextureMode.Depth;
            }
            Graphics.Blit(src, dst, fogEffectMaterial);
        }
    }

}
