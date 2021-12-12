#ifndef __COMMON_INCLUDED__
#define __COMMON_INCLUDED__

#include "Types.hlsl"

inline float Random(float2 uv)
{
	return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453123);
}

inline double RandomRange(float2 uv, float min, float max) {
	// Returns a random real in [min,max).
	return min + (max - min) * Random(uv);
}

/*
// Uniformaly distributed points on a unit sphere
// http://mathworld.wolfram.com/SpherePointPicking.html
float3 RandomUnitVector(uint seed)
{
	float PI2 = 6.28318530718;
	float z = 1 - 2 * random(seed);
	float xy = sqrt(1.0 - z * z);
	float sn, cs;
	sincos(PI2 * random(seed + 1), sn, cs);
	return float3(sn * xy, cs * xy, z);
}
*/

float3 RandomInUnitSphere(float3 seed)
{
	float2 Rand = float2(Random(seed.xy), Random(seed.xy + seed.z));
	Rand = 2.0 * (Rand - 0.5); // [0..1] -> [-1..1]
	
	float ang1 = (Rand.x + 1.0) * PI; // [-1..1) -> [0..2*PI)
	float u = Rand.y; // [-1..1), cos and acos(2v-1) cancel each other out, so we arrive at [-1..1)
	float u2 = u * u;
	float sqrt1MinusU2 = sqrt(1.0 - u2);
	float x = sqrt1MinusU2 * cos(ang1);
	float y = sqrt1MinusU2 * sin(ang1);
	float z = u;
	return float3(x, y, z);
}

float3 RandomInUnitDisk(float3 seed)
{
	float2 Rand = float2(Random(seed.xy), Random(seed.xy + seed.z));
	Rand = 2.0 * (Rand - 0.5); // [0..1] -> [-1..1]
	return float3(normalize(Rand), 0.0);
}
////////////////////////////////////////////////////////////////////////////////////

bool NearZero(float3 v)
{
	const float s = EPSILON;
	return (abs(v.x) < s) && (abs(v.y) < s) && (abs(v.z) < s);
}

float3 Reflect(float3 v, float3 n)
{
	return v - 2 * dot(v, n)*n;
}

float3 Refract(float3 uv, float3 n, float etai_over_etat)
{
	float cos_theta = min(dot(-uv, n), 1.0);
	float3 r_out_perp = etai_over_etat * (uv + cos_theta * n);
	float3 r_out_parallel = -sqrt(abs(1.0 - dot(r_out_perp, r_out_perp))) * n;
	return r_out_perp + r_out_parallel;
}

float Reflectance(float cosine, float ref_idx)
{
	// Use Schlick's approximation for reflectance.
	float r0 = (1 - ref_idx) / (1 + ref_idx);
	r0 = r0 * r0;
	return r0 + (1 - r0) * pow((1 - cosine), 5);
}


#endif // __UTILITY_INCLUDED__