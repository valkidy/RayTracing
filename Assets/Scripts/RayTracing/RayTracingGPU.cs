using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using Sphere = RayTracing.Sphere;
using World = RayTracing.World;

public class RayTracingGPU : MonoBehaviour
{
    [SerializeField] Shader shader = default;
    [SerializeField] [Range(0f, 0.3f)] float aperture = 0.1f;
    [SerializeField] [Range(1e-3f, 20f)] float focusDist = 10f;
    float aspectRatio = 16f / 9f;

    Material material;
    ComputeBuffer StructureSphereDataBuffer;
    ComputeBuffer StructureCameraDataBuffer;
    RenderTexture renderTexture;
   
    // Start is called before the first frame update
    void Start()
    {
        int imageWidth = Screen.width; // 400
        int imageHeight = (int)(imageWidth / aspectRatio);

        material = new Material(shader);
        renderTexture = new RenderTexture(imageWidth, imageHeight, 0, RenderTextureFormat.ARGB32);

        // Buffer
        (var SphereData, var NumSpheres) = World.RandomScene();

        StructureSphereDataBuffer = new ComputeBuffer(256, Marshal.SizeOf(typeof(Sphere)));
        StructureSphereDataBuffer.SetData(SphereData);
        StructureCameraDataBuffer = new ComputeBuffer(1, Marshal.SizeOf(typeof(RayTracing.Camera)));

        material.SetBuffer("_SphereData", StructureSphereDataBuffer);
        material.SetInt("_NumSpheres", NumSpheres);

        material.EnableKeyword("ENABLE_GAMMA_CORRECTION");
        material.EnableKeyword("ENABLE_MATERIAL");
        material.EnableKeyword("ENABLE_DOF");
    }

    void OnDestroy()
    {
        DestroyImmediate(material);
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
        material.SetBuffer("_CameraData", StructureCameraDataBuffer);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Graphics.Blit(source, destination, material);

        Graphics.Blit(source, renderTexture, material);
        Graphics.Blit(renderTexture, destination);
    }
}
