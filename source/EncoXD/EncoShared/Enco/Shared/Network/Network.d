module Enco.Shared.Network.Network;

import EncoShared;

interface IPacket
{
	@property u32 length();
	void[] serialize();
	void deserialize(void[]);
}

class StringPacket : IPacket
{
	private string content;

	public this(string content = "")
	{
		this.content = content;
	}

	public @property u32 length()
	{
		return cast(u32)(content.length + 1);
	}

	public @property string text()
	{
		return content;
	}

	public @property void text(string c)
	{
		content = c;
	}

	public void[] serialize()
	{
		void[] data = cast(void[])(content.idup ~ '\0');
		return data[0 .. length];
	}

	public void deserialize(void[] buf)
	{
		content = cast(immutable(char)[])(buf);
	}
}
