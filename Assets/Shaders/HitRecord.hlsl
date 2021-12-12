#ifndef __HITRECORD_INCLUDED__
#define __HITRECORD_INCLUDED__

#include "Types.hlsl"

void HitRecord_SetFaceNormal(inout HitRecord rec, Ray r, float3 outward_normal)
{
	rec.bFrontFace = (dot(r.Dir, outward_normal) < 0);
	rec.Normal = rec.bFrontFace ? outward_normal : -outward_normal;
}

HitRecord _HitRecord(in Ray r, in Sphere s, float t)
{
	HitRecord rec = (HitRecord)0;
	rec.t = t;
	rec.P = Ray_At(r, t);
	float3 outward_normal = (rec.P - s.Center) / s.Radius;
	HitRecord_SetFaceNormal(rec, r, outward_normal);
	rec.Mat = s.Mat;

	return rec;
}

#endif // __HITRECORD_INCLUDED__