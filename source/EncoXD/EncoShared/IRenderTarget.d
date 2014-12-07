module Enco.Shared.IRenderTarget;

import EncoShared;

interface IRenderTarget
{
	void init(u32 width, u32 height, bool depth);

	void capture();

	void display(i32 colorID, i32 depthID);
}