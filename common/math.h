// (C)2006 Garena Shanghai
// math.h
// 
// Basic math operations & enhanced rendering functions
//=============================================================================
#ifndef MATH_H
#define MATH_H

//=============================================================================
// Global variables
//=============================================================================


//=============================================================================
// Functions
//=============================================================================


float2 UVRotate(float2 vUV, float fAngle)
{
	float sinAngle = sin(fAngle);
	float cosAngle = cos(fAngle);

	float vUVCentered = vUV - 0.5f;

	float2x2 mRot = float2x2(cosAngle, sinAngle, -sinAngle, cosAngle);
	vUVCentered = mul(vUVCentered, mRot);

	vUV = vUVCentered + 0.5f;

	return vUV;
}


//=============================================================================
// Additional Power Functions (Pow2/Pow4 are in fog.h for universal access)
// Pow5 is primarily used for Schlick Fresnel approximation
//=============================================================================
float3 Pow2(float3 x) { return x * x; }
float Pow5(float x) { float x2 = x * x; return x2 * x2 * x; }


//=============================================================================
// Schlick Fresnel Approximation (Optimized)
// F = F0 + (1 - F0) * (1 - cos(theta))^5
// Uses manual multiply chain instead of pow() for ~2x faster execution
//=============================================================================
float SchlickFresnel(float fF0, float fNdotV)
{
	float f = 1.0f - fNdotV;
	float f2 = f * f;
	return fF0 + (1.0f - fF0) * f2 * f2 * f;
}

float3 SchlickFresnel3(float3 vF0, float fNdotV)
{
	float f = 1.0f - fNdotV;
	float f2 = f * f;
	float f5 = f2 * f2 * f;
	return vF0 + (1.0f - vF0) * f5;
}



//=============================================================================
// Fake Subsurface Scattering (SSS)
// Approximates light transmission through thin surfaces
// (skin, ears, leaves, cloth)
// Cost: ~4 ALU instructions — negligible impact
//=============================================================================
float3 FakeSSS(float3 vNormal, float3 vLightDir, float3 vViewDir,
               float3 vLightColor, float fThickness)
{
	float fVdotL = saturate(dot(vViewDir, -vLightDir));
	float fWrap = saturate(dot(-vNormal, vLightDir) * 0.5f + 0.5f);
	return vLightColor * (fVdotL * fWrap * fThickness);
}


#endif // MATH_H
