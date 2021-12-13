using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using Sphere = RayTracing.Sphere;
using World = RayTracing.World;

public class RayTracingGPU : MonoBehaviour
{
    [SerializeField] Shader shader;

    Material material;
    ComputeBuffer dataBuffer;
    ComputeBuffer cameraBuffer;
    RenderTexture renderTexture;
    float aspectRatio = 16f / 9f;
    int image_width = 400;
    int image_height = 400 * 9 / 16;

    // Start is called before the first frame update
    void Start()
    {
        material = new Material(shader);
        renderTexture = new RenderTexture(image_width, image_height, 0, RenderTextureFormat.ARGB32);

        // Buffer
        (var SphereData, var NumSpheres) = World.RandomScene();
        
        dataBuffer = new ComputeBuffer(256, Marshal.SizeOf(typeof(Sphere)));        
        dataBuffer.SetData(SphereData);
        cameraBuffer = new ComputeBuffer(1, Marshal.SizeOf(typeof(RayTracing.Camera)));

        material.SetBuffer("_SphereData", dataBuffer);
        material.SetInt("_NumSpheres", NumSpheres);
    }

    void OnDestroy()
    {
        DestroyImmediate(material);
        renderTexture?.Release();

        dataBuffer?.Dispose();
        dataBuffer = null;
        cameraBuffer?.Dispose();
        cameraBuffer = null;
    }

    void FixedUpdate()
    {
        var c = Camera.main;
        var Cam = World.Camera(c.transform.position, Vector3.zero, Vector3.up, 20f, aspectRatio, 0.1f, 10f);
        cameraBuffer.SetData(new RayTracing.Camera[] { Cam });
        material.SetBuffer("_CameraData", cameraBuffer);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
        // Graphics.Blit(source, renderTexture, material);
        // Graphics.Blit(renderTexture, destination);
    }
}
