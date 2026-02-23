// (C)2006 S2 Games
// fog.h
// 
// Fog support functions
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================
float		fFogStart;
float		fFogEnd;
float		fFogDelta;
float		fFogScale;
float3		vFogColor;
float		fFogDensity;
float3		vFog;

//=============================================================================
// Fog
//=============================================================================
float	Fog(float3 PositionView)
{
#if (FOG_TYPE == 0) // FOG_NONE
	return 0.0f;
#elif (FOG_TYPE == 1) // FOG_LINEAR
	return saturate(length(PositionView) * vFog.x + vFog.y) * vFog.z;
#elif (FOG_TYPE == 2) // FOG_EXP2
	return 1.0f - exp2(-length(PositionView) * fFogDensity);
#elif (FOG_TYPE == 3) // FOG_EXP
	return 1.0f - exp(-length(PositionView) * fFogDensity);
#elif (FOG_TYPE == 4) // FOG_HERMITE
	return smoothstep(fFogStart, fFogEnd, length(PositionView)) * fFogScale;
#endif
}


//=============================================================================
// FogD
//=============================================================================
float	FogD(float fDistance)
{
#if (FOG_TYPE == 0) // FOG_NONE
	return 0.0f;
#elif (FOG_TYPE == 1) // FOG_LINEAR
	return saturate(fDistance * vFog.x + vFog.y) * vFog.z;
#elif (FOG_TYPE == 2) // FOG_EXP2
	return 1.0f - exp2(-fDistance * fFogDensity);
#elif (FOG_TYPE == 3) // FOG_EXP
	return 1.0f - exp(-fDistance * fFogDensity);
#elif (FOG_TYPE == 4) // FOG_HERMITE
	return smoothstep(fFogStart, fFogEnd, fDistance) * fFogScale;
#endif
}


//=============================================================================
// ACES Filmic Tonemapping (Stephen Hill's fit)
// Industry-standard curve used in Unreal Engine, Unity, film VFX
// S-curve: lifts shadows, adds contrast, compresses highlights smoothly
// Input: linear HDR color   Output: display-ready LDR color
//=============================================================================
float3 ACESFilm(float3 x)
{
	x *= 0.8f;  // Exposure reduction — prevents washed-out brightness
	float a = 2.51f;
	float b = 0.03f;
	float c = 2.43f;
	float d = 0.59f;
	float e = 0.14f;
	return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}


//=============================================================================
// Optimized Power Functions
// Manual multiply chains: 1-2 ALU slots vs pow() LOG+MUL+EXP (3 slots)
//=============================================================================
float Pow2(float x) { return x * x; }
float Pow4(float x) { float x2 = x * x; return x2 * x2; }
float3 Pow4(float3 x) { float3 x2 = x * x; return x2 * x2; }


//=============================================================================
// Energy Conserving Blinn-Phong Specular (Gentle)
// Uses sqrt of full normalization, capped at 1.5x original intensity
// Preserves artist-tuned specular while adding subtle physical correctness
//=============================================================================
float EnergyConservingSpecular(float fNdotH, float fSpecPower, float fSpecIntensity)
{
	float fNorm = min(sqrt((fSpecPower + 2.0f) * 0.125f), 1.5f);
	return pow(fNdotH, fSpecPower) * fNorm * fSpecIntensity;
}