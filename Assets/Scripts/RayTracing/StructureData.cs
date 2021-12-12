using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

namespace RayTracing
{
    public enum MaterialType
    {
        MAT_LAMBERTIAN = 0,
        MAT_METAL = 1,
        MAT_DIELECTRIC = 2,
    }

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct Material // 24
    {
        public int Type;
        public Vector3 Albedo;
        public float Fuzz;
        public float Ir; // index_of_refraction;
    };

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct Sphere // 16 + 24
    {
        public Vector3 Center;
        public float Radius;
        public Material Mat;
    };

    public class World
    {
        public static Material Material(MaterialType Type, Vector3 Albedo, float Fuzz=0f)
        {            
            Material Mat = new Material();
            Mat.Type = (int)Type;
            Mat.Albedo = Albedo;
            Mat.Fuzz = Fuzz;
            return Mat; 
        }

        public static Material Material(MaterialType Type, float Ir)
        {
            Material Mat = new Material();
            Mat.Type = (int)Type;            
            Mat.Ir = Ir;
            return Mat;
        }

        public static Sphere Sphere(Vector3 Center, float Radius, Material Mat)
        {
            Sphere Sph = new Sphere();
            Sph.Center = Center;
            Sph.Radius = Radius;
            Sph.Mat = Mat;
            return Sph;
        }

        public static (Sphere[], int) RandomScene()
        {
            Sphere[] SphereData = new Sphere[256];
            int NumSpheres = 0;

            var GroundMaterial = Material(MaterialType.MAT_LAMBERTIAN, new Vector3(0.5f, 0.5f, 0.5f));
            SphereData[NumSpheres++] = Sphere(new Vector3(0, -1000, 0), 1000, GroundMaterial);

            Material SphereMaterial = default;

            for (int a = -4; a < 5; a++)
            {
                for (int b = -4; b < 5; b++)
                {
                    var ChooseMat = Random.Range(0.0f, 1.0f);
                    var Center = new Vector3(a + 0.9f * Random.Range(0.0f, 1.0f), 0.2f, b + 0.9f * Random.Range(0.0f, 1.0f));

                    if (Vector3.Distance(Center, new Vector3(4f, 0.2f, 0)) > 0.9)
                    {
                        if (ChooseMat < 0.8)
                        {
                            // diffuse
                            var Albedo = new Vector3(Random.Range(0f, 1f), Random.Range(0f, 1f), Random.Range(0f, 1f));
                            SphereMaterial = Material(MaterialType.MAT_LAMBERTIAN, Albedo);
                            SphereData[NumSpheres++] = Sphere(Center, 0.2f, SphereMaterial);
                        }
                        else if (ChooseMat < 0.95)
                        {
                            // metal
                            var Albedo = new Vector3(Random.Range(0.5f, 1f), Random.Range(0.5f, 1f), Random.Range(0.5f, 1f));
                            var Fuzz = Random.Range(0, 0.5f);
                            SphereMaterial = Material(MaterialType.MAT_METAL, Albedo, Fuzz);
                            SphereData[NumSpheres++] = Sphere(Center, 0.2f, SphereMaterial);
                        }
                        else
                        {
                            // glass     
                            SphereMaterial = Material(MaterialType.MAT_DIELECTRIC, 1.5f);
                            SphereData[NumSpheres++] = Sphere(Center, 0.2f, SphereMaterial);
                        }
                    }
                }
            }

            SphereMaterial = Material(MaterialType.MAT_DIELECTRIC, 1.5f);
            SphereData[NumSpheres++] = Sphere(new Vector3(0, 1, 0), 1.0f, SphereMaterial);

            SphereMaterial = Material(MaterialType.MAT_LAMBERTIAN, new Vector3(0.4f, 0.2f, 0.1f));
            SphereData[NumSpheres++] = Sphere(new Vector3(-4, 1, 0), 1.0f, SphereMaterial);

            SphereMaterial = Material(MaterialType.MAT_METAL, new Vector3(0.7f, 0.6f, 0.5f), 0.0f);            
            SphereData[NumSpheres++] = Sphere(new Vector3(4, 1, 0), 1.0f, SphereMaterial);            

            return (SphereData, NumSpheres);
        }

        public static (Sphere[], int) RandomScene2()
        {
            Sphere[] SphereData = new Sphere[256];
            int NumSpheres = 0;            

            var material_ground = Material(MaterialType.MAT_LAMBERTIAN, new Vector3(0.8f, 0.8f, 0.0f));
            var material_center = Material(MaterialType.MAT_LAMBERTIAN, new Vector3(0.1f, 0.2f, 0.3f));            
            var material_left = Material(MaterialType.MAT_DIELECTRIC, 1.5f);
            var material_right = Material(MaterialType.MAT_METAL, new Vector3(0.8f, 0.6f, 0.2f), 0.0f);

            SphereData[NumSpheres++] = Sphere(new Vector3(0, -100.5f, -1), 100.0f, material_ground);
            SphereData[NumSpheres++] = Sphere(new Vector3(0, 0, -1), 0.5f, material_center);
            SphereData[NumSpheres++] = Sphere(new Vector3(-1, 0, -1), 0.5f, material_left);
            SphereData[NumSpheres++] = Sphere(new Vector3(-1, 0, -1), -0.4f, material_left);
            SphereData[NumSpheres++] = Sphere(new Vector3(1, 0, -1), 0.5f, material_right);
            return (SphereData, NumSpheres);
        }
    }
}
