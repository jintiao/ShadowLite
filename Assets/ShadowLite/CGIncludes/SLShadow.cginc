#ifndef SL_SHADOW_INCLUDED
#define SL_SHADOW_INCLUDED

//UNITY_DECLARE_SHADOWMAP(_ShadowMapTexture);
uniform sampler2D _SLShadowTex;
uniform float4x4 _SLWorldToShadow;

half SLComputeForwardShadows(float3 worldPos)
{
	float4 clipPos = mul(_SLWorldToShadow, worldPos);
	if (clipPos.x > clipPos.w || clipPos.x < -clipPos.w)
		return 1;
	if (clipPos.y > clipPos.w || clipPos.y < -clipPos.w)
		return 1;

	float2 uv = (clipPos.xy - clipPos.w) * 0.5 / clipPos.w;
	float z = clipPos.z / clipPos.w;
	float shadowDepth = tex2D(_SLShadowTex, uv);

	if (z > shadowDepth)
		return 0.3;
	return 1;
}

#endif // #ifndef SL_SHADOW_INCLUDED
