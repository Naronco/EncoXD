module Enco.Shared.Render.ITexture;

import EncoShared;
import std.stdio;

interface ITexture
{
	void create(u32 width, u32 height, void[] pixels);

	void load(string file);

	void fromSurface(Bitmap surface, string name = "Surface");

	Bitmap toSurface();

	void destroy();

	void resize(u32 width, u32 height, void[] pixels = null);

	void bind(u32 unit);
	
	@property u32 id();

	@property u32 width();

	@property u32 height();

	static @property ITexture white();
}

interface ITexture3D
{
	void create(u32 width, u32 height, u32 depth, void[] pixels);

	void load(string file);

	void destroy();

	void resize(u32 width, u32 height, u32 depth, void[] pixels = null);

	void bind(u32 unit);

	@property u32 id();
}