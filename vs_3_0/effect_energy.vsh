// (C)2014 S2 Games
// effect_energy.vsh
// 
// An animated shader designed to simulate arcs of electricity/energy
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;  // World * View * Projection transformation

float2		vUVScale;
float2		vUVScroll;
float2		vUVScale2;
float2		vUVScroll2;
float			fTime;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color0 : COLOR0;
	float4 Texcoord0 : TEXCOORD0;
	float2 Texcoord1 : TEXCOORD1;
};

//=============================================================================
// Vertex shader input structure
//=============================================================================
struct VS_INPUT
{
	float3 Position  : POSITION;
	float4 Color0    : COLOR0;
	float4 Texcoord0 : TEXCOORD0;
};

//=============================================================================
// Vertex Shader
//=============================================================================
VS_OUTPUT VS( VS_INPUT In )
{
	VS_OUTPUT Out;

	Out.Position	= mul(float4(In.Position, 1.0f), mWorldViewProj);
	Out.Texcoord0.xy	= In.Texcoord0.xy * vUVScale * (1.0f + In.Texcoord0.w) + vUVScroll * fTime;
	Out.Texcoord0.zw	= In.Texcoord0.xy * vUVScale2 * (1.0f + In.Texcoord0.w) + vUVScroll2 * fTime;
	Out.Texcoord1	= In.Texcoord0;
	Out.Color0		= In.Color0;

	//Out.Position	= mul(float4(In.Position, 1.0f), mWorldViewProj);
	//Out.Texcoord0.xy	= In.Texcoord0.xy;
	//Out.Texcoord0.z		= 1.0f + In.Texcoord0.w;
	//Out.Color0		= In.Color0;

	return Out;
}