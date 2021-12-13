using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using Sphere = RayTracing.Sphere;
using World = RayTracing.World;

public class RayTracingCS : MonoBehaviour
{
    [SerializeField] ComputeShader shader = default;
    [SerializeField] [Range(0f, 0.3f)] float aperture = 0.1f;
    [SerializeField] [Range(1e-3f, 20f)] float focusDist = 10f;
    float aspectRatio = 16f / 9f;
    
    ComputeBuffer StructureSphereDataBuffer;
    ComputeBuffer StructureCameraDataBuffer;
    RenderTexture renderTexture;

    int imageWidth;
    int imageHeight;
    const int NUM_THREADS = 8;
    int Kernel;

    // Start is called before the first frame update
    void Start()
    {
        imageWidth = Screen.width / 2;
        imageHeight = (int)(imageWidth / aspectRatio);
        
        renderTexture = new RenderTexture(imageWidth, imageHeight, 0, RenderTextureFormat.ARGB32);
        renderTexture.enableRandomWrite = true;
        renderTexture.Create();
       
        // Buffer
        (var SphereData, var NumSpheres) = World.RandomScene();

        StructureSphereDataBuffer = new ComputeBuffer(256, Marshal.SizeOf(typeof(Sphere)));
        StructureSphereDataBuffer.SetData(SphereData);
        StructureCameraDataBuffer = new ComputeBuffer(1, Marshal.SizeOf(typeof(RayTracing.Camera)));

        Kernel = shader.FindKernel("ComputerRayTracing");
        shader.SetBuffer(Kernel, "_SphereData", StructureSphereDataBuffer);        
        shader.SetInt("_NumSpheres", NumSpheres);
        shader.SetTexture(Kernel, "_MainTex", renderTexture);
        shader.SetVector("_MainTex_TexelSize", new Vector4(1f/imageWidth, 1f/imageHeight, imageWidth, imageHeight));
    }

    void OnDestroy()
    {        
        renderTexture?.Release();

        StructureSphereDataBuffer?.Dispose();
        StructureSphereDataBuffer = null;
        StructureCameraDataBuffer?.Dispose();
        StructureCameraDataBuffer = null;
    }

    void FixedUpdate()
    {
        var c = Camera.main;
        var Cam = World.Camera(c.transform.position, Vector3.zero, Vector3.up, 20f, aspectRatio, aperture, focusDist);
        StructureCameraDataBuffer.SetData(new RayTracing.Camera[] { Cam });
        shader.SetBuffer(Kernel, "_CameraData", StructureCameraDataBuffer);

        shader.Dispatch(Kernel, Mathf.CeilToInt((float)imageWidth / NUM_THREADS), Mathf.CeilToInt((float)imageHeight / NUM_THREADS), 1);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {        
        Graphics.Blit(renderTexture, destination);
    }
}

