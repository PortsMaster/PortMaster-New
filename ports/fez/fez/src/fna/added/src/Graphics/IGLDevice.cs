#region Using Statements
using System;
#endregion

namespace Microsoft.Xna.Framework.Graphics
{
	/* Games written against pre-FNA3D versions of FNA (FEZ, for one) reflect
	 * into GraphicsDevice's private GLDevice field and read capabilities off
	 * of it through the IGLDevice interface. FNA3D replaced that object with a
	 * bare handle, so wrap the handle in something that still answers those
	 * queries.
	 */
	internal interface IGLDevice
	{
		bool SupportsHardwareInstancing
		{
			get;
		}

		int MaxMultiSampleCount
		{
			get;
		}
	}

	internal sealed class GLDeviceHandle : IGLDevice
	{
		private readonly IntPtr handle;

		private GLDeviceHandle(IntPtr handle)
		{
			this.handle = handle;
		}

		public bool SupportsHardwareInstancing
		{
			get
			{
				return FNA3D.FNA3D_SupportsHardwareInstancing(handle) != 0;
			}
		}

		public int MaxMultiSampleCount
		{
			get
			{
				return FNA3D.FNA3D_GetMaxMultiSampleCount(
					handle,
					SurfaceFormat.Color,
					8
				);
			}
		}

		public static implicit operator IntPtr(GLDeviceHandle device)
		{
			return device.handle;
		}

		public static implicit operator GLDeviceHandle(IntPtr handle)
		{
			return new GLDeviceHandle(handle);
		}
	}
}
