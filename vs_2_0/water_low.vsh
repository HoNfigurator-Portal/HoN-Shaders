// (C)2009 S2 Games
// mesh_color_water5.vsh
// 
// ...
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

float4		vSunPositionWorld;

float3		vAmbient;
float3		vSunColor;

float4		vColor;

float4x4	mSceneProj;

float		fTime;
float 		fSpeed;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color0 : COLOR0;
	float4 Texcoord0 : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float4 PositionScreen : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 DiffLight : TEXCOORDX;
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
	float2 Texcoord0  : TEXCOORD0;
	float4 Tangent    : TEXCOORD1;
#endif
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;
	
	
	float3 vInNormal = (In.Normal / 255.0f) * 2.0f - 1.0f;
	float4 vInTangent = (In.Tangent / 255.0f) * 2.0f - 1.0f;
	
	float4 vPosition = float4(In.Position, 1.0f);
	float3 vNormal = vInNormal;
	float3 vTangent = vInTangent.xyz;

	float3 vPositionOffset = mul(vPosition, mWorldViewOffset).xyz;
	
	Out.Position      = mul(vPosition, mWorldViewProj);
	Out.Color0        = vColor;
	Out.Color0.a *= Out.Color0.a;
	Out.Texcoord0.xy  = In.Texcoord0 + float2(fSpeed * fTime, fSpeed * fTime);
	Out.Texcoord0.zw  = In.Texcoord0 * -1.5f + float2(fSpeed * fTime, fSpeed * fTime);
	Out.PositionScreen = mul(Out.Position, mSceneProj);

	float3 vLight = vSunPositionWorld.xyz;
	float3 vWVNormal = mul(vNormal, mWorldRotate);

	float fDiffuse = saturate(dot(vWVNormal, vLight));
	Out.DiffLight      = vSunColor * fDiffuse;
	Out.Color0.rgb *= 1.5f;

	return Out;
}
