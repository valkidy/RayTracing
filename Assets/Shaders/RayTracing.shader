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
			#pragma multi_compile __ ENABLE_GAMMA_CORRECTION
			#pragma multi_compile __ ENABLE_MATERIAL
			#pragma multi_compile __ ENABLE_DOF

			#include "VertImg.hlsl"
			#include "RayTracing.hlsl"

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
#if ENABLE_MATERIAL						
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
			
			int _NumSpheres;
			StructuredBuffer<Sphere> _SphereData;			
			StructuredBuffer<Camera> _CameraData;

			half4 frag(v2f i) : SV_Target
			{
				HittableList world = _HittableList(_SphereData, _NumSpheres);

				// Camera
				Camera cam = _CameraData[0];

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
