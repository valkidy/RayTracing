Shader "Unlit/RayTracing"
{
	Properties
	{
		[HideInInspector] _MainTex("Texture", 2D) = "white" {}
	}
	
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "VertImg.hlsl"
			#include "RayTracing.hlsl"

			#define ENABLE_GAMMA_CORRECTION	 1
			#define DIFFUSE 1

			float3 Ray_Color(in Ray r, in HittableList world, in float2 uv) {
				
				HitRecord rec = (HitRecord)0;
				Ray R = r;
				float3 Factor = (float3)1.0;
				
				// Temp
				Ray Scattered = (Ray)0;
				float3 Attenuation = (float3)0;
								
				for (int i = 0; i < MAX_DEPTH; i++)
				{
					
					if (HittableList_Hit(world, R, FLT_MIN, FLT_MAX, rec))
					{
						float Offset = 2.0 * (((float)i) / (float)(MAX_DEPTH)-0.5);
						float3 seed = float3(uv, Offset);
#if DIFFUSE						
						if (Material_Scatter(rec.Mat, R, rec, Attenuation, Scattered, seed))
						{
							R = Scattered;
							Factor *= Attenuation;
						}
						else
						{
							return (float3)0;
						}
#else						
						float3 target = rec.P + rec.Normal + RandomInUnitSphere(seed);
						R = _Ray(rec.P, target - rec.P);
						Factor *= 0.5;
#endif
					}
					else
					{
						float3 unit_direction = normalize(r.Dir);
						float t = 0.5 * (unit_direction.y + 1.0);
						return Factor * lerp(float3(1.0, 1.0, 1.0), float3(0.5, 0.7, 1.0), t);
					}
				}
				return (float3)0;
			}			
			
			StructuredBuffer<Sphere> _SphereData;
			int _NumSpheres;

			half4 frag(v2f i) : SV_Target
			{
				// Image
				float aspect_ratio = 16.0 / 9.0;
#if 1
				HittableList world = _HittableList(_SphereData, _NumSpheres);
#else
				HittableList world = (HittableList)0;
				Material material_ground = _Lambertian(float3(0.8, 0.8, 0.0));
				Material material_center = _Lambertian(float3(0.1, 0.2, 0.3));
				Material material_left = _Dielectric(1.5);
				Material material_right = _Metal(float3(0.8, 0.6, 0.2), 0.0);

				world.Objects[0] = _Sphere(float3(0.0, -100.5, -1.0), 100.0, material_ground);
				world.Objects[1] = _Sphere(float3(0.0, 0.0, -1.0), 0.5, material_center);
				world.Objects[2] = _Sphere(float3(-1.0, 0.0, -1.0), 0.5, material_left);
				world.Objects[3] = _Sphere(float3(-1.0, 0.0, -1.0), -0.4, material_left);
				world.Objects[4] = _Sphere(float3(1.0, 0.0, -1.0), 0.5, material_right);
				world.NumObjects = 5;
#endif
				float3 lookfrom = float3(13, 2, 3);
				float3 lookat = float3(0, 0, 0);
				float3 vup = float3(0, 1, 0);
				float dist_to_focus = 10.0;// length(lookfrom - lookat);
				float aperture = 0.1; // 2.0;
			
				
				// Camera
				// Camera cam = _Camera();
				Camera cam = _Camera(lookfrom, lookat, vup, 20, aspect_ratio, aperture, dist_to_focus);

				float3 color = (float3)0;

				[loop]
				for (int s = 0; s < SAMPLES_PER_PIXEL; s++)
				{
					float2 Seed = i.screenPos.xy;
					float Offset = 2.0 * (float(s) / float(SAMPLES_PER_PIXEL) - 0.5);
					float2 Jitter = float2(Random(Seed), Random(Seed + Offset));					
					float2 UV = i.screenPos.xy + Jitter * _MainTex_TexelSize.xy;
					
					Ray r = Camera_GetRay(cam, UV);
					color += Ray_Color(r, world, UV);
				}
#if ENABLE_GAMMA_CORRECTION				
				color = saturate(sqrt(color / float(SAMPLES_PER_PIXEL)));				
#else
				color /= float(SAMPLES_PER_PIXEL);
#endif				
				return half4(color, 1.0);
			}
			ENDCG
		}
	}
}
