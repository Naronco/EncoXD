module EncoShared.Render.IRenderTarget;

import EncoShared;

interface IRenderTarget
{
	void init(uint width, uint height, bool depth, IView view);

	void resize(uint width, uint height);

	void bind();

	void unbind();

	@property ITexture color();
	@property ITexture depth();
	@property IView view();
}
