// (C)2006 S2 Games
// common.h
// 
// Support functions and macros
// Updated: 2026 Modernization - HDR, PBR, SSAO macros
//=============================================================================

//=============================================================================
// TEXCOORDX
//=============================================================================
#define CURRENT_COORD	0
#define TEXCOORDC(c)	TEXCOORD##c
#define TEXCOORDX TEXCOORDC(CURRENT_COORD)

//=============================================================================
// Global variables
//=============================================================================


//=============================================================================
// 2026 MODERNIZATION: HDR Macros
//=============================================================================

// HDR enable/disable
#ifndef HDR
#define HDR 1
#endif

// HDR Exposure
#ifndef HDR_EXPOSURE
#define HDR_EXPOSURE 1.0f
#endif

// Tonemapping modes
#ifndef TONEMAP_ACES
#define TONEMAP_ACES 0
#endif

#ifndef TONEMAP_REINHARD
#define TONEMAP_REINHARD 0
#endif

#ifndef TONEMAP_HABLE
#define TONEMAP_HABLE 0
#endif

//=============================================================================
// 2026: PBR Macros
//=============================================================================

// PBR enable/disable
#ifndef PBR
#define PBR 0
#endif

// PBR Quality levels
#ifndef PBR_QUALITY
#define PBR_QUALITY 1
#endif

// Metallic/Roughness workflow
#ifndef PBR_METALLIC
#define PBR_METALLIC 1
#endif

//=============================================================================
// 2026: SSAO Macros
//=============================================================================

// SSAO enable/disable
#ifndef SSAO
#define SSAO 0
#endif

// SSAO Quality (0=off, 1=low, 2=medium, 3=high)
#ifndef SSAO_QUALITY
#define SSAO_QUALITY 2
#endif

// SSAO Radius
#ifndef SSAO_RADIUS
#define SSAO_RADIUS 0.5f
#endif

// SSAO Intensity
#ifndef SSAO_INTENSITY
#define SSAO_INTENSITY 1.0f
#endif

//=============================================================================
// 2026: Shadow Macros
//=============================================================================

// Shadow quality
#ifndef SHADOWS
#define SHADOWS 1
#endif

// VSM (Variance Shadow Maps)
#ifndef SHADOW_VSM
#define SHADOW_VSM 0
#endif

// PCSS (Percentage-Closer Soft Shadows)
#ifndef SHADOW_PCSS
#define SHADOW_PCSS 0
#endif

// Shadow Cascades (CSM)
#ifndef SHADOW_CASCADES
#define SHADOW_CASCADES 0
#endif

//=============================================================================
// 2026: Post-Processing Macros
//=============================================================================

// Bloom enable
#ifndef BLOOM
#define BLOOM 1
#endif

// Bloom quality
#ifndef BLOOM_QUALITY
#define BLOOM_QUALITY 2
#endif

// Motion Blur
#ifndef MOTION_BLUR
#define MOTION_BLUR 1
#endif

// TAA (Temporal Anti-Aliasing)
#ifndef TAA
#define TAA 0
#endif

// FXAA
#ifndef FXAA
#define FXAA 1
#endif

//=============================================================================
// 2026: Water Macros
//=============================================================================

// Water quality
#ifndef WATER_QUALITY
#define WATER_QUALITY 2
#endif

// Gerstner waves
#ifndef WATER_GERSTNER
#define WATER_GERSTNER 1
#endif

// Water foam
#ifndef WATER_FOAM
#define WATER_FOAM 1
#endif

//=============================================================================
// Utility Macros
//=============================================================================

// Check if feature is enabled
#define IS_ENABLED(x) ((x) != 0)

// Get quality level (0=low, 1=med, 2=high)
#define QUALITY(level) level
