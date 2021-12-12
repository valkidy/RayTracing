#ifndef __MATERIAL_INCLUDED__
#define __MATERIAL_INCLUDED__

//Material _Material(int type, float3 albedo, float fuzz)
//{
//	Material m = (Material)0;
//	m.Type = type;
//	m.Albedo = albedo;
//	m.Fuzz = (fuzz < 1) ? fuzz : 1.0;
//	m.IR = fuzz;
//
//	return m;
//}

Material _Lambertian(float3 albedo)
{
	Material m = (Material)0;
	m.Type = MAT_LAMBERTIAN;
	m.Albedo = albedo;
	return m;
}

Material _Metal(float3 albedo, float fuzz)
{
	Material m = (Material)0;
	m.Type = MAT_METAL;
	m.Albedo = albedo;
	m.Fuzz = (fuzz < 1) ? fuzz : 1.0;
	return m;
}

Material _Dielectric(float index_of_refraction)
{
	Material m = (Material)0;
	m.Type = MAT_DIELECTRIC;
	m.IR = index_of_refraction;
	return m;
}
////////////////////////////////////////////////////////////////////////////////////
bool Lambertian_Scatter(inout Material m, Ray r, HitRecord rec, inout float3 attenuation, inout Ray scattered, float3 seed)
{
	float3 ScatterDirection = rec.Normal + RandomInUnitSphere(seed);
	// Catch degenerate scatter direction
	if (NearZero(ScatterDirection))
		ScatterDirection = rec.Normal;
	scattered = _Ray(rec.P, ScatterDirection);
	attenuation = m.Albedo;
	return true;
}

bool Metal_Scatter(inout Material m, Ray r, HitRecord rec, inout float3 attenuation, inout Ray scattered, float3 seed)
{
	float3 Reflected = Reflect(normalize(r.Dir), rec.Normal);
	scattered = _Ray(rec.P, Reflected + (m.Fuzz * RandomInUnitSphere(seed)));
	attenuation = m.Albedo;
	return (dot(scattered.Dir, rec.Normal) > 0);
}

bool Dielectric_Scatter(inout Material m, Ray r, HitRecord rec, inout float3 attenuation, inout Ray scattered, float3 seed)
{
	attenuation = float3(1.0, 1.0, 1.0);
	float RefractionRatio = rec.bFrontFace ? (1.0 / m.IR) : m.IR;

	float3 UnitDir = normalize(r.Dir);
	float CosTheta = min(dot(-UnitDir, rec.Normal), 1.0);
	float SinTheta = sqrt(1.0 - CosTheta * CosTheta);

	bool bCannotRefract = RefractionRatio * SinTheta > 1.0;
	float3 Direction;

	if (bCannotRefract || (Reflectance(CosTheta, RefractionRatio) > Random(seed.yz)))
		Direction = Reflect(UnitDir, rec.Normal);
	else
		Direction = Refract(UnitDir, rec.Normal, RefractionRatio);

	scattered = _Ray(rec.P, Direction);
	return true;
}

bool Material_Scatter(in Material m, in Ray r, in HitRecord rec, inout float3 attenuation, inout Ray scattered, in float3 seed)
{
	if (MAT_LAMBERTIAN == m.Type)
	{
		return Lambertian_Scatter(m, r, rec, attenuation, scattered, seed);
	}
	else if (MAT_METAL == m.Type)
	{
		return Metal_Scatter(m, r, rec, attenuation, scattered, seed);
	}
	else if (MAT_DIELECTRIC == m.Type)
	{
		return Dielectric_Scatter(m, r, rec, attenuation, scattered, seed);
	}
	return false;
}


#endif // __MATERIAL_INCLUDED__