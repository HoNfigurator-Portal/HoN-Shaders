// (C)2011 S2 Games
// post_outline_d_h.vsh
// 
// ...
//=============================================================================

//=============================================================================
// Constants
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;  // World * View * Projection transformation
float4		vTexelSize;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position  : POSITION;
	float2 Texcoord0 : TEXCOORD0;
	float4 Texcoord1 : TEXCOORD1;
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float2 Position  : POSITION;
	float4 Color0    : COLOR0;
	float2 Texcoord0 : TEXCOORD0;
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;

	float4 v = float4(In.Position.x, In.Position.y, 0.0f, 1.0f);

	Out.Position	= mul(v, mWorldViewProj);
	
	// Pack Texcoords to save additions in pixel shader
	Out.Texcoord0 = In.Texcoord0;
	Out.Texcoord1.xy = In.Texcoord0 + float2(-vTexelSize.x, 0.0f);
	Out.Texcoord1.zw = In.Texcoord0 + float2(vTexelSize.x, 0.0f);
	
	return Out;
}

