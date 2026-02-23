// (C)2006 S2 Games
// shadowed.h
// 
// Shadowmap support functions
//=============================================================================

//=============================================================================
// Global variables
//=============================================================================
float	fShadowmapSize;
float	fShadowmapSizeInv;

float2	vShadowFalloff;
float2	vShadowLeak;

sampler	shadowmap;

//=============================================================================
// Poisson Disk offsets for smoother shadow edges
//=============================================================================
static const float2 vPoissonDisk[8] = {
	float2(-0.7071f,  0.7071f),
	float2( 0.0000f, -0.8750f),
	float2( 0.5303f,  0.5303f),
	float2(-0.6250f,  0.0000f),
	float2( 0.3536f, -0.6124f),
	float2(-0.3536f,  0.6124f),
	float2( 0.8750f,  0.0000f),
	float2(-0.4677f, -0.4677f)
};

//=============================================================================
// ShadowedR32F
//=============================================================================
float	ShadowedR32F(float4 TexcoordLight)
{
#if (SHADOWMAP_FILTER_WIDTH > 0)
	float fShadow = 0.0f;
	float3 vShadowTexcoord = (TexcoordLight.xyz / TexcoordLight.w);
	float fRadius = fShadowmapSizeInv * float(SHADOWMAP_FILTER_WIDTH);
	
	// Poisson Disk PCF - smoother shadow edges than grid sampling
	[unroll] for (int i = 0; i < 8; i++)
	{
		float2 vOffset = vPoissonDisk[i] * fRadius;
		float2 vSampleCoord = vShadowTexcoord.xy + vOffset;
		
		// Bilinear PCF per sample
		float2 vFrac = frac(fShadowmapSize * vSampleCoord);
		
		float4 vSamples;
		vSamples[0] = tex2D(shadowmap, vSampleCoord).r;
		vSamples[1] = tex2D(shadowmap, vSampleCoord + float2(fShadowmapSizeInv, 0.0f)).r;
		vSamples[2] = tex2D(shadowmap, vSampleCoord + float2(0.0f, fShadowmapSizeInv)).r;
		vSamples[3] = tex2D(shadowmap, vSampleCoord + float2(fShadowmapSizeInv, fShadowmapSizeInv)).r;
		
		float4 vShadowTest = step(vShadowTexcoord.z, vSamples);
		fShadow += lerp(lerp(vShadowTest[0], vShadowTest[1], vFrac.x), lerp(vShadowTest[2], vShadowTest[3], vFrac.x), vFrac.y);
	}

	return saturate(fShadow * 0.125f * vShadowLeak.x + vShadowLeak.y);

#else // SHADOWMAP_FILTER_WIDTH == 0
	float3 vShadowTexcoord = TexcoordLight.xyz / TexcoordLight.w;
	return saturate((tex2D(shadowmap, vShadowTexcoord.xy).r > vShadowTexcoord.z) * vShadowLeak.x + vShadowLeak.y); 
#endif
}


//=============================================================================
// ShadowedDepth
//=============================================================================
float	ShadowedDepth(float4 TexcoordLight)
{
#if (SHADOWMAP_FILTER_WIDTH > 1)

	float fShadow = 0.0f;
	float fRadius = fShadowmapSizeInv * float(SHADOWMAP_FILTER_WIDTH);
	
	// Poisson Disk PCF for smoother shadow edges
	[unroll] for (int i = 0; i < 8; i++)
	{
		float2 vOffset = vPoissonDisk[i] * fRadius * TexcoordLight.w;
		fShadow += tex2Dproj(shadowmap,
				float4(TexcoordLight.xy + vOffset,
						TexcoordLight.z,
						TexcoordLight.w)).r;
	}

	return saturate(fShadow * 0.125f * vShadowLeak.x + vShadowLeak.y);

#else // SHADOWMAP_FILTER_WIDTH == 0

	return saturate(tex2Dproj(shadowmap, TexcoordLight).r * vShadowLeak.x + vShadowLeak.y);

#endif
}


//=============================================================================
// Shadowed
//=============================================================================
float	Shadowed(float4 TexcoordLight)
{
#if (SHADOWMAP_TYPE == 0) // SHADOWMAP_R32F
	return ShadowedR32F(TexcoordLight);
#elif (SHADOWMAP_TYPE == 1) // SHADOWMAP_DEPTH
	return ShadowedDepth(TexcoordLight);
#endif
}


//=============================================================================
// ShadowedD
//=============================================================================
float	ShadowedD(float4 TexcoordLight, float fDistance)
{
#ifdef SHADOW_FALLOFF
	float fFade = saturate(fDistance * vShadowFalloff.x + vShadowFalloff.y);
#else
	float fFade = 0.0f;
#endif

#if (SHADOWMAP_TYPE == 0) // SHADOWMAP_R32F
	return saturate(ShadowedR32F(TexcoordLight) + fFade);
#elif (SHADOWMAP_TYPE == 1) // SHADOWMAP_DEPTH
	return saturate(ShadowedDepth(TexcoordLight) + fFade);
#endif
}