#ifndef __CAMERA_INCLUDED__
#define __CAMERA_INCLUDED__

Camera _Camera()
{
	float aspect_ratio = 16.0 / 9.0;
	float viewport_height = 2.0;
	float viewport_width = aspect_ratio * viewport_height;
	float focal_length = 1.0;

	Camera cam = (Camera)0;
	cam.Origin = float3(0, 0, 0);
	cam.Horizontal = float3(viewport_width, 0.0, 0.0);
	cam.Vertical = float3(0.0, viewport_height, 0.0);
	cam.LowerLeftCorner = cam.Origin - cam.Horizontal / 2 - cam.Vertical / 2 - float3(0, 0, focal_length);
	return cam;
}

Camera _Camera(float3 look_from, float3 look_at, float3 vup,
	float vfov, float aspect_ratio,
	float aperture, float focus_dist)
{
	Camera Cam;

	float Theta = vfov * PI / 180.0;
	float h = tan(Theta / 2);
	float ViewportHeight = 2.0 * h;
	float ViewportWidth = aspect_ratio * ViewportHeight;

	Cam.w = normalize(look_from - look_at);
	Cam.u = normalize(cross(vup, Cam.w));
	Cam.v = cross(Cam.w, Cam.u);

	Cam.Origin = look_from;
	Cam.Horizontal = focus_dist * ViewportWidth * Cam.u;
	Cam.Vertical = focus_dist * ViewportHeight * Cam.v;
	Cam.LowerLeftCorner = Cam.Origin - Cam.Horizontal / 2 - Cam.Vertical / 2 - focus_dist * Cam.w;

	Cam.LensRadius = aperture / 2.0;

	return Cam;
}

Ray Camera_GetRay(in Camera c, float2 uv)
{
#if 0
	float3 rd = c.LensRadius * RandomDiskPoint(float3(uv, 0.4), c.w);
	float3 Offset = c.u * rd.x + c.v * rd.y;

	return _Ray(c.Origin + Offset, c.LowerLeftCorner + uv.x * c.Horizontal + uv.y * c.Vertical - c.Origin - Offset);
#endif
	return _Ray(c.Origin, c.LowerLeftCorner + uv.x * c.Horizontal + uv.y * c.Vertical - c.Origin);
}

#endif // __CAMERA_INCLUDED__