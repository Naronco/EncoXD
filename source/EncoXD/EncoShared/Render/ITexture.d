module Enco.Shared.Render.ITexture;

import EncoShared;
import std.stdio;

interface ITexture
{
	void create(u32 width, u32 height, void* pixels);

	void load(string file);

	void destroy();

	void resize(u32 width, u32 height, void* pixels = null);

	void bind(u32 unit);

	@property u32 id();
}

interface ITexture3D
{
	void create(u32 width, u32 height, u32 depth, void* pixels);

	void load(string file);

	void destroy();

	void resize(u32 width, u32 height, u32 depth, void* pixels = null);

	void bind(u32 unit);

	@property u32 id();
}