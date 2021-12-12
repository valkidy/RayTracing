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
	Rand -= 0.5f;
	Rand *= 2.0f;
	float ang1 = (Rand.x + 1.0) * PI; // [-1..1) -> [0..2*PI)
	float u = Rand.y; // [-1..1), cos and acos(2v-1) cancel each other out, so we arrive at [-1..1)
	float u2 = u * u;
	float sqrt1MinusU2 = sqrt(1.0 - u2);
	float x = sqrt1MinusU2 * cos(ang1);
	float y = sqrt1MinusU2 * sin(ang1);
	float z = u;
	return float3(x, y, z);
}

#endif // __UTILITY_INCLUDED__