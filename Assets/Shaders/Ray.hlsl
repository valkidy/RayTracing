#ifndef __RAY_INCLUDED__
#define __RAY_INCLUDED__

inline Ray _Ray(float3 o, float3 d)
{
	Ray R = (Ray)0;
	R.Origin = o;
	R.Dir = d;
	return R;
}

inline float3 Ray_At(in Ray r, float t) {
	return (r.Origin + t * r.Dir);
}


#endif // __RAY_INCLUDED__