#ifndef __SPHERE_INCLUDED__
#define __SPHERE_INCLUDED__

#include "Types.hlsl"
#include "HitRecord.hlsl"

inline Sphere _Sphere(float3 c, float r, Material m)
{
	Sphere s = (Sphere)0;
	s.Center = c;
	s.Radius = r;
	s.Mat = m;

	return s;
}

bool Sphere_Hit(in Sphere s, in Ray r, float t_min, float t_max, inout HitRecord rec)
{
	float3 oc = r.Origin - s.Center;
	float a = dot(r.Dir, r.Dir);
	float half_b = dot(oc, r.Dir);
	float c = dot(oc, oc) - s.Radius * s.Radius;

	float discriminant = half_b * half_b - a * c;
	if (discriminant < 0) return false;
	float sqrtd = sqrt(discriminant);

	// Find the nearest root that lies in the acceptable range.
	float root = (-half_b - sqrtd) / a;
	if (root < t_min || t_max < root) {
		root = (-half_b + sqrtd) / a;
		if (root < t_min || t_max < root)
			return false;
	}

	rec = _HitRecord(r, s, root);	

	return true;
}

#endif // __SPHERE_INCLUDED__