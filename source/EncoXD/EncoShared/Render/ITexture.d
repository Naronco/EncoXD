module EncoShared.Render.ITexture;

import EncoShared;
import std.stdio;

interface ITexture
{
	void create(uint width, uint height, void[] pixels);

	void fromBitmap(Bitmap bitmap, string name = "Bitmap");

	Bitmap toBitmap();

	void destroy();

	void resize(uint width, uint height, void[] pixels = null);

	void bind(uint unit);

	@property uint id();

	@property uint width();

	@property uint height();

	static @property ITexture white();
}

interface ITexture3D
{
	void create(uint width, uint height, uint depth, void[] pixels);

	void fromBitmap(Bitmap bitmap, string name = "Bitmap");

	void destroy();

	void resize(uint width, uint height, uint depth, void[] pixels = null);

	void bind(uint unit);

	@property uint id();

	@property uint width();

	@property uint height();

	@property uint depth();
}
