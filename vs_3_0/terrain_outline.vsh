// (C)2006 S2 Games
// terrain_color.vsh
// 
// Terrain
//=============================================================================

//=============================================================================
// Headers
//=============================================================================
#include "../common/common.h"

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;	         // World * View * Projection transformation
float3		vWorldSizes;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float  Height    : POSITION;
	float4 Color0    : COLOR0;
	float4 Data0     : TEXCOORD0;
	float4 Data1     : TEXCOORD1;
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;
	
	float2 vTile = float2(In.Data0.w, In.Data1.w);
	float4 vPosition = float4(vTile * vWorldSizes.x, In.Height, 1.0f);
	Out.Position      = mul(vPosition, mWorldViewProj);

	return Out;
}
