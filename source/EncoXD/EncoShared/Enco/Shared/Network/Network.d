module Enco.Shared.Network.Network;

import std.bitmanip;

import EncoShared;

///
interface IPacket
{
	@property ushort id();
	/// Streams should be Big Endian
	ubyte[] serialize();
	/// Streams should be Big Endian
	void deserialize(ref ubyte[] stream);
}

/// Length prefixed string packet with maximum length ushort.max with default id 65500
class StringPacket : IPacket
{
private:
	string m_content;

public:
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
	}

	static ushort PACKET_ID = 65500;
}
