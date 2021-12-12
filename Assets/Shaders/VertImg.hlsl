#ifndef __VERT_IMG_INCLUDED__
#define __VERT_IMG_INCLUDED__

#include "UnityCG.cginc"

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD;
};

struct v2f
{
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD;
	float3 screenPos : TEXCOORD2;
};

float4 _MainTex_TexelSize;

v2f vert_img(appdata v)
{
	v2f o = (v2f)0;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;
	o.screenPos = ComputeScreenPos(o.pos);
	return o;
}

#endif // __VERT_IMG_INCLUDED__