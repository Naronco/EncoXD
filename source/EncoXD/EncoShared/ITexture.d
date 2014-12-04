module Enco.Shared.ITexture;

import EncoShared;
import std.stdio;

interface ITexture
{
	void create(u32 width, u32 height, void* pixels);

	void load(string file);

	void destroy();

	void bind(u32 unit);
}