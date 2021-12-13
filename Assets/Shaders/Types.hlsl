#ifndef __TYPES_INCLUDED__
#define __TYPES_INCLUDED__

#define PI						3.14159265359

#define FLT_MIN					1e-3
#define FLT_MAX					1e12
#define EPSILON					1e-8
#define SAMPLES_PER_PIXEL		8 //16
#define MAX_DEPTH				6 //8

#define MAT_LAMBERTIAN			0
#define MAT_METAL				1
#define MAT_DIELECTRIC			2 

// feature 
#define ENABLE_GAMMA_CORRECTION	 1
////////////////////////////////////////////////////////////////////////////////////

struct Material
{
	int Type;
	float3 Albedo;
	float Fuzz;
	float IR;
};

////////////////////////////////////////////////////////////////////////////////////

struct Camera {
	float3 Origin;
	float3 LowerLeftCorner;
	float3 Horizontal;
	float3 Vertical;
	float3 u, v, w;
	float LensRadius;
};

////////////////////////////////////////////////////////////////////////////////////

struct Ray {
	float3 Origin;
	float3 Dir;
};

////////////////////////////////////////////////////////////////////////////////////
struct Sphere {
	float3 Center;
	float Radius;
	Material Mat;
};

////////////////////////////////////////////////////////////////////////////////////
struct HittableList
{
	// Sphere Objects[32];
	StructuredBuffer<Sphere> Objects;
	int NumObjects;
};

////////////////////////////////////////////////////////////////////////////////////

struct HitRecord
{
	float3 P;
	float3 Normal;
	float t;
	bool bFrontFace;
	Material Mat;
};

#endif // __TYPES_INCLUDED__
