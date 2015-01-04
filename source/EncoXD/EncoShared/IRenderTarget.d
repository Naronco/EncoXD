module Enco.Shared.Render.IRenderTarget;

import EncoShared;

interface IRenderTarget
{
	void init(u32 width, u32 height, bool depth);

	void resize(u32 width, u32 height);

	void bind();

	void unbind();
	
	@property ITexture color();
	@property ITexture depth();
}