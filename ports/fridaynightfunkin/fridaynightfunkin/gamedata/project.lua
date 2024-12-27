return {
	DEBUG_MODE = true,
	splashScreen = true,

	title = "Friday Night Funkin' Löve",
	file = "FNF-LOVE",
	icon = "art/icon.png",
	version = "0.7.0",
	package = "com.stilic.fnflove",
	width = 1280,
	height = 720,
	FPS = 60,
	company = "Stilic",

	flags = {
		checkForUpdates = false,

		loxelInitialAutoPause = true,
		loxelInitialParallelUpdate = true,
		loxelInitialAsyncInput = false,

		loxelForceRenderCameraComplex = false,
		loxelDisableRenderCameraComplex = false,
		loxelDisableScissorOnRenderCameraSimple = false,
		loxelDefaultClipCamera = true
	}
}
