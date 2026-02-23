// (C)2014 S2 Games
// effect_water.vsh
// 
// Particle water shader
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
float4x4	mSceneProj;

float2		vUVScale;
float2		vUVScroll;
float2		vUVScale2;
float2		vUVScroll2;

float			fHeight;

float		fTime;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color0 : COLOR0;
	float4 PositionScreen : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float4 Texcoord0 : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float4 Texcoord1 : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 PositionOffset : TEXCOORDX;
		#include "../common/inc_texcoord.h"
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
	float4 Texcoord0 : TEXCOORD0;
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
	
	Out.PositionOffset = vPositionOffset;
	
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

	Out.Position       = mul(float4(In.Position + float4(0, 0, fHeight, 0), 1.0f), mWorldViewProj);
	Out.Texcoord0.xy   = In.Texcoord0 * vUVScale + fTime * vUVScroll;
	Out.Texcoord0.zw   = In.Texcoord0.zw;
	Out.Texcoord1.xy   = In.Texcoord0 * vUVScale2 + fTime * vUVScroll2;
	Out.Texcoord1.zw   = In.Texcoord0.xy;
	Out.Color0         = In.Color0;
	Out.PositionScreen = mul(Out.Position, mSceneProj);

	return Out;
}