// (C)2006 S2 Games
// mesh_depth_opacity.vsh
// 
// Renders alpha-tested depth
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================


#if (FOLIAGE == 1)
float4		vFoliage;
float		fTime;
float4x4	mWorld;
float4x4	mViewProj;
float4		vTreeFoliage;
#else
float4x4	mWorldViewProj;          // World * View * Projection transformation
#endif

#if (NUM_BONES > 0)
float4x3	vBones[NUM_BONES];
#endif

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float2 Texcoord0 : TEXCOORD0;
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float3 Position   : POSITION;
#if (TEXCOORDS > 0)
	float2 Texcoord0  : TEXCOORD0;
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
	
#if (NUM_BONES > 0)
	float3 vPosition = 0.0f;

	//
	// GPU Skinning
	// Blend bone matrix transforms for this bone
	//
	
	int4 vBlendIndex = In.BoneIndex;
	float4 vBoneWeight = In.BoneWeight / 255.0f;
	
	float4x3 mBlend = 0.0f;
	for (int i = 0; i < NUM_BONE_WEIGHTS; ++i)
		mBlend += vBones[vBlendIndex[i]] * vBoneWeight[i];

	vPosition = mul(float4(In.Position, 1.0f), mBlend);
#else
	float3 vPosition = In.Position;
#endif
	
	
#if (FOLIAGE == 1)
	const float PI = 3.14159265358979323846f;
	float4 vPosition2 = mul(float4(vPosition, 1.0f), mWorld);
	float fPositionOff = dot(normalize(vPosition2.xyz), vTreeFoliage.z);
	float fXT = (fPositionOff * PI);
	float fPhaseBrushOffset = vPosition.z * vTreeFoliage.w * cos((fTime + fXT) * vFoliage.z) * vFoliage.w;
	vPosition2.x += fPhaseBrushOffset * vTreeFoliage.x;
	vPosition2.y += fPhaseBrushOffset * vTreeFoliage.y;
	Out.Position = mul(vPosition2, mViewProj);
#else
	Out.Position = mul(float4(vPosition, 1.0f), mWorldViewProj);
#endif

#if (TEXCOORDS == 1)
	Out.Texcoord0      = In.Texcoord0;
#else
	Out.Texcoord0      = float2(0.0f, 0.0f);
#endif

	return Out;
}
