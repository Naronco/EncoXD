module Enco.Shared.Network.Network;

import EncoShared;

interface IPacket
{
	@property u32 length();
	byte[] serialize();
	void deserialize(byte[]);
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

	public byte[] serialize()
	{
		byte[] data = new byte[length];

		foreach(int i, immutable(char) c; content)
		{
			data[i] = cast(byte)c;
		}

		data[data.length - 1] = '\0';

		return data;
	}

	public void deserialize(byte[] buf)
	{
		char[] c = new char[buf.length];

		foreach(int i, byte b; buf)
		{
			c[i] = cast(char)b;
		}

		content = c.idup;
	}
}
