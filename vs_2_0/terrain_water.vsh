// (C)2006 S2 Games
// terrain_color.vsh
// 
// Terrain
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
float4x4	mWorldViewOffset;	     // World * View  (No Scale)
float4x4	mWorld;			         // World transformation
float4x4	mWorldRotate;

float4		vSunPositionWorld;

float3		vAmbient;
float3		vSunColor;

float3		vWorldSizes;

float		fTime;
float3		vTextureParams;
float2		vRotation;

#if (SHADOWS == 1)
float4x4	mLightWorldViewProjTex;  // Light's World * View * Projection * Tex
#endif

#ifdef CLOUDS
float4x4	mCloudProj;
#endif

#if (FOG_OF_WAR == 1)
float4x4	mFowProj;
#endif

float4x4	mSceneProj;

float		fReflectionHeight;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float ReflectionPow : COLOR0;
	float4 Texcoord0 : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float2 Texcoord1 : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float4 PositionScreen : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#if (LIGHTING_QUALITY == 0 || FALLOFF_QUALITY == 0)
	float3 PositionOffset : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#endif
#if (LIGHTING_QUALITY == 0)
	float3 Normal : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 Tangent : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 Binormal : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#elif (LIGHTING_QUALITY == 1)
	float3 HalfAngle : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 SunLight : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 Reflect : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#elif (LIGHTING_QUALITY == 2)
	float3 Reflect : TEXCOORDX;
		#include "../common/inc_texcoord.h"
	float3 DiffLight : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#endif
#if (SHADOWS == 1)
	float4 TexcoordLight : TEXCOORDX; // Texcoord in light texture space
		#include "../common/inc_texcoord.h"
#endif
#ifdef CLOUDS
	float2 TexcoordClouds : TEXCOORDX;
			#include "../common/inc_texcoord.h"
#endif
#if ((FOG_QUALITY == 1 && FOG_TYPE != 0) || (FALLOFF_QUALITY == 1 && (FOG_TYPE != 0 || SHADOWS == 1)) || FOG_OF_WAR == 1)
	float4 Last : TEXCOORDX;
		#include "../common/inc_texcoord.h"
#endif
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float4 Position    		: POSITION0;
	float4 Data0    	 	: TEXCOORD0;
	float4 Data1     		: TEXCOORD1;
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;
	
#if ((FOG_QUALITY == 1 && FOG_TYPE != 0) || (FALLOFF_QUALITY == 1 && (FOG_TYPE != 0 || SHADOWS == 1)) || FOG_OF_WAR == 1)
	Out.Last = 0;
#endif
	
	float2 vTile = float2(In.Data0.w, In.Data1.w);
	float4 vPosition = float4(vTile * vWorldSizes.x, In.Position.x, 1.0f);
	
	float2x2 TextureRotM2 = float2x2(vRotation.y, -vRotation.x, vRotation.x, vRotation.y);
	
	float3x3 TextureRotM3 = float3x3
	(vRotation.y, -vRotation.x, 0.0f,
	 vRotation.x, vRotation.y, 0.0f, 
	 0.0f,     0.0f,    1.0f); 
	 
	float3 vNormal = In.Data0.xyz / 255.0f * 2.0f - 1.0f;
	
	float3 vTangent = In.Data1.xyz / 255.0f * 2.0f - 1.0f;
	vTangent = mul(TextureRotM3, vTangent);
	vTangent = normalize(vTangent);
	
	float3 vPositionOffset = mul(vPosition, mWorldViewOffset).xyz;
	
	float3 vPositionWorld = mul(vPosition, mWorld).xyz;
	
	float2 vTexcoord0 = mul(vPositionWorld.xy * vTextureParams.x * 0.01f, TextureRotM2);
	float2 vTexcoord1 = mul(vPositionWorld.xy * vTextureParams.y * 0.01f, TextureRotM2);	
	
	Out.Position      = mul(vPosition, mWorldViewProj);
	
	Out.ReflectionPow  = clamp(50.0f - abs(In.Position.x - fReflectionHeight), 0.0f, 50.0f) / 50.0f;
	
		//x is reflection map alpha y is diffuse alpha
	//Out.Alpha.x		  = In.Position.y;
	//Out.Alpha.y		  = In.Position.z;
	
	float fDistance = length(vPositionWorld);
	
	float fTexFrameMove = (fTime * vTextureParams.z);
	Out.Texcoord0.xy  = vTexcoord0 + fTexFrameMove;
	Out.Texcoord0.zw  = vTexcoord1 * -1.5f + fTexFrameMove;
	
	Out.Texcoord1.xy = vPositionWorld.xy;
	
	Out.PositionScreen = mul(Out.Position, mSceneProj);

	


#if (LIGHTING_QUALITY == 0 || FALLOFF_QUALITY == 0)
	Out.PositionOffset  = vPositionOffset;
#endif
#if (FALLOFF_QUALITY == 1 && (FOG_TYPE != 0 || SHADOWS == 1))
	Out.Last.z = fDistance;
#endif
	
#if (LIGHTING_QUALITY == 0)
	Out.Normal        = mul(mWorldRotate, vNormal);
	Out.Tangent       = mul(mWorldRotate, vTangent);
	Out.Binormal      = cross(Out.Tangent, Out.Normal);
	
#elif (LIGHTING_QUALITY == 1)
	float3 vCamDirection = -normalize(vPositionOffset);
	float3 vLight = vSunPositionWorld.xyz;
	float3 vWVNormal = vNormal;
	float3 vWVTangent = vTangent;
	float3 vWVBinormal = cross(vWVTangent, vWVNormal);

	float3x3 mRotate = transpose(float3x3(vWVTangent, vWVBinormal, vWVNormal));
	
	Out.SunLight      = mul(vLight, mRotate);
	Out.HalfAngle     = mul(normalize(vLight + vCamDirection), mRotate);
	Out.Reflect        = reflect(vPositionOffset, vWVNormal);
#elif (LIGHTING_QUALITY == 2)
	float3 vLight = vSunPositionWorld.xyz;		
	float3 vWVNormal = mul(mWorldRotate, vNormal);

	
	Out.Reflect        = reflect(vPositionOffset, vWVNormal);
	float fDiffuse = saturate(dot(vWVNormal, vLight));

	Out.DiffLight     = vSunColor * fDiffuse;
#endif

#if (SHADOWS == 1)
	Out.TexcoordLight = mul(vPosition, mLightWorldViewProjTex);
#endif

#ifdef CLOUDS
	Out.TexcoordClouds = mul(vPosition, mCloudProj).xy;
#endif

#if (FOG_QUALITY == 1 && FOG_TYPE != 0)
	Out.Last.w = Fog(vPositionOffset);
#endif

#if (FOG_OF_WAR == 1)
	Out.Last.xy = mul(vPosition, mFowProj).xy;
#endif

	return Out;
}
