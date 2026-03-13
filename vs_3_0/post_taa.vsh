// (C)2026 Modernization
// post_taa.vsh
// 
// TAA Vertex Shader - 2026
//=============================================================================

#include "../common/common.h"

float4x4	mWorldViewProj;

struct VS_OUTPUT
{
	float2 Texcoord0 : TEXCOORD0;
	float4 Position : POSITION;
};

struct VS_INPUT
{
	float3 Position : POSITION;
	float2 Texcoord0 : TEXCOORD0;
};

VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;
	Out.Position = mul(float4(In.Position, 1.0f), mWorldViewProj);
	Out.Texcoord0 = In.Texcoord0;
	return Out;
}
