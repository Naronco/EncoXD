module EncoShared.Network.ArrayPackets;

import std.bitmanip;

import EncoShared;

/// Length prefixed array packet template with constant length and length >= 2 elements with maximum length ushort.max
mixin template CommonArrayPacket(ElemType, ushort defaultPacketId)
{
	static assert(ElemType.sizeof >= 2, "ElemType.sizeof < 2. Consider using StringPacket or (U)ByteArrayPacket instead");

private:
	ElemType[] m_content;

public:
	alias m_content this;

	this(ElemType[] content = [])
	{
		m_content = content;
	}

	@property ushort id()
	{
		return PACKET_ID;
	}

	@property ref ElemType[] content()
	{
		return m_content;
	}

	ubyte[] serialize()
	{
		ubyte[] data = nativeToBigEndian(cast(ushort) (m_content.length * ElemType.sizeof));
		foreach (ref ElemType child; m_content)
			data ~= nativeToBigEndian(child);
		return data;
	}

	void deserialize(ref ubyte[] stream)
	{
		ushort length = stream.read!ushort ();
		m_content.length = length / ElemType.sizeof;

		for (ushort i = 0; i < length; i++)
			m_content[i] = stream.read!ElemType ();

		stream = stream[length .. $];
	}

	static ushort PACKET_ID = defaultPacketId;
}

/// Length prefixed ushort[] packet with maximum length of ushort.max with default id 65401
class UShortArrayPacket : IPacket
{
	mixin CommonArrayPacket!(ushort, 65401);
}

/// Length prefixed short[] packet with maximum length of ushort.max with default id 65402
class ShortArrayPacket : IPacket
{
	mixin CommonArrayPacket!(short, 65402);
}

/// Length prefixed uint[] packet with maximum length of ushort.max with default id 65403
class UIntArrayPacket : IPacket
{
	mixin CommonArrayPacket!(uint, 65403);
}

/// Length prefixed int[] packet with maximum length of ushort.max with default id 65404
class IntArrayPacket : IPacket
{
	mixin CommonArrayPacket!(int, 65404);
}

/// Length prefixed ulong[] packet with maximum length of ushort.max with default id 65405
class ULongArrayPacket : IPacket
{
	mixin CommonArrayPacket!(ulong, 65405);
}

/// Length prefixed long[] packet with maximum length of ushort.max with default id 65406
class LongArrayPacket : IPacket
{
	mixin CommonArrayPacket!(long, 65406);
}

/// Length prefixed float[] packet with maximum length of ushort.max with default id 65407
class FloatArrayPacket : IPacket
{
	mixin CommonArrayPacket!(float, 65407);
}

/// Length prefixed double[] packet with maximum length of ushort.max with default id 65408
class DoubleArrayPacket : IPacket
{
	mixin CommonArrayPacket!(double, 65408);
}
