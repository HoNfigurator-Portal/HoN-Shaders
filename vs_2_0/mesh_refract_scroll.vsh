// (C)2008 S2 Games
// mesh_color_unit_scene.vsh
// 
// ...
//=============================================================================

//=============================================================================
// Headers
//=============================================================================
#include "../common/common.h"
#include "../common/fog.h"

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;	         // World * View * Projection transformation
float4x4	mWorldView;	             // World * View
float3x3	mWorldViewRotate;        // World rotation for normals

float4		vColor;

#if (NUM_BONES > 0)
float4x3	vBones[NUM_BONES];
#endif

float4x4	mSceneProj;

float2		vUVScale;
float2		vUVScroll;
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
	float3 Normal : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 Tangent : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 Binormal : TEXCOORDX;
		#include "../common/inc_texcoord.h"
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float3 Position   : POSITION;
	float3 Normal     : NORMAL;
#if (TEXCOORDS == 1)
	float4 Texcoord0  : TEXCOORD0;
	float4 Tangent    : TEXCOORD1;
#endif
#if (NUM_BONES > 0)
	int4 BoneIndex    : TEXCOORD_BONEINDEX;
	float4 BoneWeight : TEXCOORD_BONEWEIGHT;
#endif
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;
	
	float3 vInNormal = (In.Normal / 255.0f) * 2.0f - 1.0f;
#if (TEXCOORDS == 1)
	float4 vInTangent = (In.Tangent / 255.0f) * 2.0f - 1.0f;
#else
	float4 vInTangent = float4(1.0f, 0.0f, 0.0f, 1.0f);
#endif
	
#if (NUM_BONES > 0)
	float4 vPosition = 0.0f;
	float3 vNormal = 0.0f;
	float3 vTangent = 0.0f;

	//
	// GPU Skinning
	// Blend bone matrix transforms for this bone
	//
	
	int4 vBlendIndex = In.BoneIndex;
	float4 vBoneWeight = In.BoneWeight / 255.0f;
	
	float4x3 mBlend = 0.0f;
	for (int i = 0; i < NUM_BONE_WEIGHTS; ++i)
		mBlend += vBones[vBlendIndex[i]] * vBoneWeight[i];

	vPosition = float4(mul(float4(In.Position, 1.0f), mBlend).xyz, 1.0f);
	vNormal = mul(float4(vInNormal, 0.0f), mBlend).xyz;
	vTangent = mul(float4(vInTangent.xyz, 0.0f), mBlend).xyz;
	
	vNormal = normalize(vNormal);
	vTangent = normalize(vTangent);
#else
	float4 vPosition = float4(In.Position, 1.0f);
	float3 vNormal = vInNormal;
	float3 vTangent = vInTangent.xyz;
#endif

	float3 vPositionView = mul(vPosition, mWorldView).xyz;
	
	Out.Position       = mul(vPosition, mWorldViewProj);
	Out.Color0         = vColor;
#if (TEXCOORDS == 1)
	Out.Texcoord0.xy      = In.Texcoord0 * vUVScale + vUVScroll * fTime;
	Out.Texcoord0.zw      = In.Texcoord0;
#else
	Out.Texcoord0      = float2(0.0f, 0.0f);
#endif
	Out.PositionScreen = mul(Out.Position, mSceneProj);
	Out.Normal         = mul(vNormal, mWorldViewRotate);
	Out.Tangent        = mul(vTangent, mWorldViewRotate);
	Out.Binormal       = cross(Out.Tangent, Out.Normal) * vInTangent.w;

	return Out;
}
