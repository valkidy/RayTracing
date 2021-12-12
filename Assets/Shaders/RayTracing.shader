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
			#include "Types.hlsl"
			#include "Common.hlsl"
			#include "Ray.hlsl"
			#include "Camera.hlsl"
			#include "Sphere.hlsl"
			#include "Hittable.hlsl"

			#define ENABLE_GAMMA_CORRECTION	 1

			float3 Ray_Color(in Ray r, in HittableList world, in float2 uv) {
				
				HitRecord rec = (HitRecord)0;
				float3 Attenuation = float3(0, 0, 0);				
				float Factor = 1.0;
				Ray R = r;
				// Ray Scattered = (Ray)0;

				
				for (int i = 0; i < MAX_DEPTH; i++)
				{
					if (HittableList_Hit(world, R, FLT_MIN, FLT_MAX, rec))
					{
						float Offset = 2.0 * (((float)i) / (float)(MAX_DEPTH) - 0.5);

						float3 target = rec.P + rec.Normal + RandomInUnitSphere(float3(uv, Offset));
						R = _Ray(rec.P, target - rec.P);
						Factor *= 0.5;
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

			half4 frag(v2f i) : SV_Target
			{
				// Image
				float aspect_ratio = 16.0 / 9.0;

				Material m = (Material)0;
				HittableList world = (HittableList)0;
				world.Objects[0] = _Sphere(float3(0, 0, -1), 0.5, m);
				world.Objects[1] = _Sphere(float3(0, -100.5, -1), 100, m);
				world.NumObjects = 2;

				// Camera
				Camera cam = _Camera();
				
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
