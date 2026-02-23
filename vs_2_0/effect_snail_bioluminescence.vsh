// effect_snail_bioluminescence.vsh
// (C)2016 Frostburn Studios
//
// Authored by Michael Olson
// 
// This shader is intended to be used on a groundsprite that moves along the 
// ground, causing patches of ground to light up as if it were emitting 
// bioluminescent light.
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;  // World * View * Projection transformation

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color0 : COLOR0;
	float4 Texcoord0 : TEXCOORD0;
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float3 Position  : POSITION;
	float4 Color0    : COLOR0;
	float2 Texcoord0 : TEXCOORD0;
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;

	Out.Position		= mul(float4(In.Position, 1.0f), mWorldViewProj);
	Out.Texcoord0.xy	= In.Texcoord0.xy;
	Out.Texcoord0.zw	= In.Position.xy;
	Out.Color0			= In.Color0;

	return Out;
}

