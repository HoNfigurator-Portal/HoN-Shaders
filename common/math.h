// (C)2006 Garena Shanghai
// math.h
// 
// Basic math operations & enhanced rendering functions
// Updated: 2026 Modernization - ACES Tonemapping, PBR, GGX
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


//=============================================================================
// 2026 MODERNIZATION: ACES Tonemapping
// Filmic tone mapping for HDR rendering
//=============================================================================

// ACES input matrix - converts linear RGB to ACES
static const float3x3 ACESInputMatrix = float3x3(
    0.59719f, 0.35458f, 0.04823f,
    0.07600f, 0.90834f, 0.01566f,
    0.02840f, 0.13383f, 0.83777f
);

// ACES output matrix - converts ACES to linear RGB
static const float3x3 ACESOutputMatrix = float3x3(
    1.60475f, -0.53108f, -0.07367f,
    -0.10208f, 1.10813f, -0.00605f,
    -0.00327f, -0.07276f, 1.07602f
);

// ACES Filmic Tone Mapping
float3 ACESFilm(float3 x)
{
	float a = 2.51f;
	float b = 0.03f;
	float c = 2.43f;
	float d = 0.59f;
	float e = 0.14f;
	return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

// Apply ACES tonemapping with input/output matrix conversion
float3 ApplyACESTonemap(float3 color)
{
	color = mul(color, ACESInputMatrix);
	color = ACESFilm(color);
	color = mul(color, ACESOutputMatrix);
	return color;
}


//=============================================================================
// 2026: Reinhard Tonemapping
// Simple and fast, preserves more brightness
//=============================================================================
float3 ReinhardTonemap(float3 x)
{
	return x / (1.0f + x);
}

// Extended Reinhard with white point
float3 ReinhardTonemapExt(float3 x, float3 whitePoint)
{
	return x * (1.0f + x / (whitePoint * whitePoint)) / (1.0f + x);
}


//=============================================================================
// 2026: Hable Tonemapping (Uncharted 2 style)
// Great dynamic range, filmic look
//=============================================================================
float3 HableTonemap(float3 x)
{
	float A = 0.15f;
	float B = 0.50f;
	float C = 0.10f;
	float D = 0.20f;
	float E = 0.02f;
	float F = 0.30f;
	
	return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}


//=============================================================================
// 2026: GGX Distribution (Normal Distribution Function)
// Cook-Torrance BRDF for PBR specular
//=============================================================================
float D_GGX(float NdotH, float roughness)
{
	float a = roughness * roughness;
	float a2 = a * a;
	float NdotH2 = NdotH * NdotH;
	
	float num = a2;
	float denom = (NdotH2 * (a2 - 1.0f) + 1.0f);
	denom = 3.14159265f * denom * denom;
	
	return num / denom;
}

// GGX Geometry function (Smith's method)
float G_SmithGGX(float NdotV, float NdotL, float roughness)
{
	float r = roughness + 1.0f;
	float k = (r * r) / 8.0f;
	
	float ggx1 = NdotV / (NdotV * (1.0f - k) + k);
	float ggx2 = NdotL / (NdotL * (1.0f - k) + k);
	
	return ggx1 * ggx2;
}


//=============================================================================
// 2026: PBR Helper Functions
//=============================================================================

// Calculate Fresnel with roughness
float3 FresnelSchlickRoughness(float NdotV, float3 F0, float roughness)
{
	return F0 + (max(float3(1.0f - roughness), F0) - F0) * pow(1.0f - NdotV, 5.0f);
}

// Convert metallic/roughness to F0
float3 GetF0(float metallic, float3 baseColor)
{
	return lerp(float3(0.04f, 0.04f, 0.04f), baseColor, metallic);
}

// Standard PBR BRDF
float3 PBRLighting(float3 N, float3 V, float3 L, float3 H, 
                   float3 baseColor, float metallic, float roughness,
                   float3 lightColor, float NdotL)
{
	float3 F0 = GetF0(metallic, baseColor);
	
	float NdotV = saturate(dot(N, V));
	float NdotH = saturate(dot(N, H));
	float NdotL_val = saturate(NdotL);
	float HdotV = saturate(dot(H, V));
	
	// Cook-Torrance BRDF
	float D = D_GGX(NdotH, roughness);
	float3 F = float3(SchlickFresnel(F0.r, HdotV), 
                      SchlickFresnel(F0.g, HdotV), 
                      SchlickFresnel(F0.b, HdotV));
	float G = G_SmithGGX(NdotV, NdotL_val, roughness);
	
	float3 specular = (D * F * G) / max(4.0f * NdotV * NdotL_val, 0.001f);
	
	// Diffuse
	float3 kD = (1.0f - F) * (1.0f - metallic);
	float3 diffuse = kD * baseColor / 3.14159265f;
	
	return (diffuse + specular) * lightColor * NdotL_val;
}


//=============================================================================
// 2026: Pack/Unpack Functions
//=============================================================================

// Pack normal to 2D
float2 PackNormal(float3 n)
{
	return n.xy * 0.5f + 0.5f;
}

// Unpack 2D to normal
float3 UnpackNormal(float2 n)
{
	return float3(n * 2.0f - 1.0f, sqrt(1.0f - saturate(dot(n, n))));
}

// Pack depth to RGBA
float4 PackDepth(float depth)
{
	float4 enc = float4(1.0f, 255.0f, 65025.0f, 16581375.0f) * depth;
	enc = frac(enc);
	enc -= enc.yzww * float4(1.0f / 255.0f, 1.0f / 255.0f, 1.0f / 255.0f, 0.0f);
	return enc;
}

// Unpack depth from RGBA
float UnpackDepth(float4 rgba)
{
	return dot(rgba, float4(1.0f, 1.0f / 255.0f, 1.0f / 65025.0f, 1.0f / 16581375.0f));
}


//=============================================================================
// 2026: Noise Functions
//=============================================================================

// Simple hash for noise
float Hash(float2 p)
{
	return frac(sin(dot(p, float2(12.9898f, 78.233f))) * 43758.5453f);
}

// Value noise
float Noise(float2 p)
{
	float2 i = floor(p);
	float2 f = frac(p);
	f = f * f * (3.0f - 2.0f * f);
	
	float a = Hash(i);
	float b = Hash(i + float2(1.0f, 0.0f));
	float c = Hash(i + float2(0.0f, 1.0f));
	float d = Hash(i + float2(1.0f, 1.0f));
	
	return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

// Fractal Brownian Motion
float FBM(float2 p, int octaves)
{
	float value = 0.0f;
	float amplitude = 0.5f;
	float frequency = 1.0f;
	
	for (int i = 0; i < octaves; i++)
	{
		value += amplitude * Noise(p * frequency);
		amplitude *= 0.5f;
		frequency *= 2.0f;
	}
	
	return value;
}


//=============================================================================
// 2026: Rotation Matrices
//=============================================================================

float3x3 RotationMatrixX(float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	return float3x3(
		1.0f, 0.0f, 0.0f,
		0.0f, c, -s,
		0.0f, s, c
	);
}

float3x3 RotationMatrixY(float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	return float3x3(
		c, 0.0f, s,
		0.0f, 1.0f, 0.0f,
		-s, 0.0f, c
	);
}

float3x3 RotationMatrixZ(float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	return float3x3(
		c, -s, 0.0f,
		s, c, 0.0f,
		0.0f, 0.0f, 1.0f
	);
}


//=============================================================================
// 2026: Gerstner Waves (Water simulation)
//=============================================================================

float3 GerstnerWave(float3 position, float time, float2 direction, 
                    float steepness, float wavelength, out float3 tangent, out float3 binormal)
{
	float k = 2.0f * 3.14159265f / wavelength;
	float c = sqrt(9.8f / k);
	float2 d = normalize(direction);
	float f = k * (dot(d, position.xz) - c * time);
	float a = steepness / k;
	
	tangent = float3(
		1.0f - d.x * d.x * steepness * sin(f),
		d.x * steepness * cos(f),
		-d.x * d.y * steepness * sin(f)
	);
	
	binormal = float3(
		-d.x * d.y * steepness * sin(f),
		d.y * steepness * cos(f),
		1.0f - d.y * d.y * steepness * sin(f)
	);
	
	return float3(
		d.x * a * cos(f),
		a * sin(f),
		d.y * a * cos(f)
	);
}


#endif // MATH_H
