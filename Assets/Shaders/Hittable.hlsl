#ifndef __HITTABLE_INCLUDED__
#define __HITTABLE_INCLUDED__

#include "Types.hlsl"
#include "Ray.hlsl"
#include "Sphere.hlsl"


bool HittableList_Hit(in HittableList hittables, in Ray r, float t_min, float t_max, inout HitRecord rec) {

	HitRecord TempRec = (HitRecord)0;
	bool bHitAnything = false;
	float ClosestSoFar = t_max;

	[loop]
	for (int i = 0; i < hittables.NumObjects; ++i) {
		Sphere s = hittables.Objects[i];
		if (Sphere_Hit(s, r, t_min, ClosestSoFar, TempRec))
		{
			bHitAnything = true;
			ClosestSoFar = TempRec.t;
			rec = TempRec;
		}
	}
	return bHitAnything;
}

#endif // __HITTABLE_INCLUDED__