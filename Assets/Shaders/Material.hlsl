#ifndef __MATERIAL_INCLUDED__
#define __MATERIAL_INCLUDED__

Material _Material(int type, float3 albedo, float fuzz)
{
	Material M;

	M.Type = type;
	M.Albedo = albedo;
	M.Fuzz = (fuzz < 1) ? fuzz : 1.0;
	M.IR = fuzz;

	return M;
}

bool Material_Scatter(inout Material m, Ray r, HitRecord rec, inout float3 attenuation, inout Ray scattered, float3 seed)
{

}


#endif // __MATERIAL_INCLUDED__