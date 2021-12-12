using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayTracingGPU : MonoBehaviour
{
    [SerializeField] Shader shader;

    Material material;
    ComputeBuffer buffer;
    RenderTexture renderTexture;
    int image_width = 400;
    int image_height = 400 * 9 / 16;

    // Start is called before the first frame update
    void Start()
    {
        material = new Material(shader);
        renderTexture = new RenderTexture(image_width, image_height, 0, RenderTextureFormat.ARGB32);
    }

    void OnDestroy()
    {
        DestroyImmediate(material);
        renderTexture?.Release();        
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(renderTexture, destination, material);
    }
}
