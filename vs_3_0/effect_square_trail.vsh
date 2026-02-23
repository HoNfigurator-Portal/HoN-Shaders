// (C)2013 S2 Games
// effect_reveal_scroll.vsh
// 
// Reveal effect shader with scrolling diffuse
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;  // World * View * Projection transformation

float2		vUVScale;
float2		vUVScroll;
float			fTime;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color0 : COLOR0;
	float3 Texcoord0 : TEXCOORD0;
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
	Out.Texcoord0.xy	= In.Texcoord0.yx * vUVScale.yx * (1.0f + In.Texcoord0.w) + -vUVScroll * fTime;
	Out.Texcoord0.z = In.Texcoord0.z;
	Out.Texcoord1.x	= 1.0f - In.Texcoord0.y;
	Out.Texcoord1.y	= 1.0f - In.Texcoord0.x;
	Out.Color0		= In.Color0;

	return Out;
}