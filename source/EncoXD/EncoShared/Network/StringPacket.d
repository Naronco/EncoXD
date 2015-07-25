module EncoShared.Network.StringPacket;

import std.bitmanip;

import EncoShared;

/// Length prefixed string packet with maximum length of ushort.max with default id 65500
class StringPacket : IPacket
{
private:
	string m_content;

public:
	alias m_content this;

	this(string content = "")
	{
		m_content = content;
	}

	@property ushort id()
	{
		return PACKET_ID;
	}

	@property ref string text()
	{
		return m_content;
	}

	ubyte[] serialize()
	{
		return nativeToBigEndian(cast(ushort)m_content.length) ~ cast(ubyte[])m_content;
	}

	void deserialize(ref ubyte[] stream)
	{
		ushort length = stream.read!ushort();
		m_content = cast(string)stream[0 .. length];
		stream = stream[length .. $];
	}

	static ushort PACKET_ID = 65500;
}
