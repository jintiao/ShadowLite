using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShadowLite
{
	[ExecuteInEditMode]
	public class SLDebugDrawDepth : MonoBehaviour
	{
		public RenderTexture depthTex;
		private Material debugMat;

		void OnRenderImage(RenderTexture source, RenderTexture destination)
		{
			if (debugMat == null)
			{
				debugMat = new Material(Shader.Find("Hidden/ShadowLite/DebugDrawDepth"));
				debugMat.SetTexture("_DepthTex", depthTex);
			}

			Graphics.Blit(source, destination, debugMat);
		}
	}
}