#ifndef SL_SHADOW_INCLUDED
#define SL_SHADOW_INCLUDED

#include "UnityCG.cginc"


sampler2D _SLShadowTex;
float4 _SLShadowTex_TexelSize;

float4x4 _SLWorldToShadow;
float4 _SLShadowData;

float SLSampleShadowmap(sampler2D tex, float3 coord)
{
	float atten = 1;
	float shadowDepth = tex2D(tex, coord.xy);
	if (coord.z < shadowDepth)
		atten = _SLShadowData.w;
	return atten;
}

float3 SLCombineShadowcoordComponents(float2 baseUV, float2 deltaUV, float depth)
{
	return float3(baseUV + deltaUV, depth);
}

float SLSampleShadowmap_PCF3x3NoHardwareSupport(float3 coord)
{
    half shadow = 1;

	float2 base_uv = coord.xy;
    float2 ts = _SLShadowTex_TexelSize.xy;
    shadow = 0;
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(-ts.x, -ts.y), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(0, -ts.y), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(ts.x, -ts.y), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(-ts.x, 0), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(0, 0), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(ts.x, 0), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(-ts.x, ts.y), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(0, ts.y), coord.z));
    shadow += SLSampleShadowmap(_SLShadowTex, SLCombineShadowcoordComponents(base_uv, float2(ts.x, ts.y), coord.z));
    shadow /= 9.0;

    return shadow;
}

float SLComputeForwardShadows(float4 clipPos)
{
	float atten = 1;

	if (clipPos.x > clipPos.w || clipPos.x < -clipPos.w)
		return atten;
	if (clipPos.y > clipPos.w || clipPos.y < -clipPos.w)
		return atten;
	if (clipPos.w < 0)
		return atten;

	float3 screenPos = clipPos.xyz / clipPos.w;
	screenPos.xy = (screenPos.xy + 1) * 0.5;

	atten = SLSampleShadowmap_PCF3x3NoHardwareSupport(screenPos);

	return atten;
}

#define SL_SHADOW_COORDS(idx1) float4 _SLShadowCoord : TEXCOORD##idx1
#define SL_TRANSFER_SHADOW(a) a._SLShadowCoord = mul(_SLWorldToShadow, mul(unity_ObjectToWorld, v.vertex))
#define SL_SHADOW_ATTENUATION(a) SLComputeForwardShadows(a._SLShadowCoord)


float4 SLClipSpaceShadowCasterPos(float4 vertex, float3 normal)
{
    float3 worldNormal = UnityObjectToWorldNormal(normal);
	float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	float shadowCos = dot(worldNormal, worldLight);
	float shadowSine = sqrt(1 - shadowCos * shadowCos);
	float normalBias = _SLShadowData.z * shadowSine;

    float4 worldPos = mul(unity_ObjectToWorld, vertex);
    worldPos.xyz -= worldNormal * normalBias;

    return mul(UNITY_MATRIX_VP, worldPos);
}

float4 SLApplyLinearShadowBias(float4 clipPos)
{
#if defined(UNITY_REVERSED_Z)
    clipPos.z -= _SLShadowData.x / clipPos.w;
#else
    clipPos.z += _SLShadowData.x / clipPos.w;
#endif
    return clipPos;
}

#define SL_V2F_SHADOW_CASTER UNITY_POSITION(pos)
#define SL_TRANSFER_SHADOW_CASTER(o) \
        o.pos = SLClipSpaceShadowCasterPos(v.vertex, v.normal); \
        o.pos = SLApplyLinearShadowBias(o.pos)
#define SL_SHADOW_CASTER_FRAGMENT(i) i.pos.z

#endif // #ifndef SL_SHADOW_INCLUDED
