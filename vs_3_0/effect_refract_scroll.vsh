// (C)2008 S2 Games
// effect_refract_scroll.vsh
// 
// Particle refraction vertex shader with scrolling UV
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================
float4x4	mWorldViewProj;  // World * View * Projection transformation
float4x4	mSceneProj;

float2		vUVScroll;
float			fTime;

//=============================================================================
// Vertex shader output structure
//=============================================================================
struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color0 : COLOR0;
	float4 Texcoord0 : TEXCOORD0;
	float4 PositionScreen : TEXCOORD1;
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

	Out.Position       = mul(float4(In.Position, 1.0f), mWorldViewProj);
	Out.Texcoord0.xy	 = In.Texcoord0.xy + vUVScroll * fTime;
	Out.Texcoord0.zw    = In.Texcoord0.zw;
	Out.PositionScreen = mul(Out.Position, mSceneProj);
	Out.Color0         = In.Color0;

	return Out;
}

