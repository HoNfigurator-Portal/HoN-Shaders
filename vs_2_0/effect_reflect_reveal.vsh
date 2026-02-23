// (C)2013 S2 Games
// effect_relect_reveal.vsh
// 
// Particle reflection vertex shader
//=============================================================================

//=============================================================================
// Headers
//=============================================================================
#include "../common/common.h"

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;          // World * View * Projection transformation
float4x4	mWorldViewOffset;        // World * View Offset
float3x3	mWorldRotate;            // World rotation for normals

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color0 : COLOR0;
	float3 Texcoord0 : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#if (LIGHTING_QUALITY == 0 || LIGHTING_QUALITY == 1 || FALLOFF_QUALITY == 0)
	float3 PositionOffset : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#endif
#if (LIGHTING_QUALITY == 0 || LIGHTING_QUALITY == 1)
	float3 Normal : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 Tangent : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 Binormal : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#elif (LIGHTING_QUALITY == 2)
	float3 Reflect : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#endif
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float3 Position  : POSITION;
	float4 Color0    : COLOR0;
	float3 Texcoord0 : TEXCOORD0;
	float3 Normal    : NORMAL;
	float4 Tangent   : TEXCOORD1;
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;

	float4 vPosition = float4(In.Position, 1.0f);
	float3 vPositionOffset = mul(vPosition, mWorldViewOffset).xyz;
	
#if (LIGHTING_QUALITY == 0 || LIGHTING_QUALITY == 1 || FALLOFF_QUALITY == 0)
	Out.PositionOffset = vPositionOffset;
#endif
	
	float3 vNormal = float3(0.0f,0.0f,1.0f);//(In.Normal / 255.0f) * 2.0f - 1.0f;
	float4 vInTangent = (In.Tangent / 255.0f) * 2.0f - 1.0f;
	float3 vTangent = vInTangent.xyz;
	
#if (LIGHTING_QUALITY == 0 || LIGHTING_QUALITY == 1)
	Out.Normal         = mul(vNormal, mWorldRotate);
	Out.Tangent        = mul(vTangent, mWorldRotate);
	Out.Binormal       = cross(Out.Tangent, Out.Normal) * vInTangent.w;
#elif (LIGHTING_QUALITY == 2)
	float3 vWVNormal   = mul(vNormal, mWorldRotate);
	Out.Reflect        = reflect(vPositionOffset, vWVNormal);
#endif

	Out.Position       = mul(float4(In.Position, 1.0f), mWorldViewProj);
	Out.Texcoord0      = In.Texcoord0;
	Out.Color0         = In.Color0;

	return Out;
}

