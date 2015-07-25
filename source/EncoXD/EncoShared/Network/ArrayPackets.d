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
		ubyte[] data = nativeToBigEndian(cast(ushort)(m_content.length * ElemType.sizeof));
		foreach(ref ElemType child; m_content)
			data ~= nativeToBigEndian(child);
		return data;
	}

	void deserialize(ref ubyte[] stream)
	{
		ushort length = stream.read!ushort();
		m_content.length = length / ElemType.sizeof;

		for(ushort i = 0; i < length; i++)
			m_content[i] = stream.read!ElemType();

		stream = stream[length .. $];
	}

	static ushort PACKET_ID = defaultPacketId;
}

/// Length prefixed ushort[] packet with maximum length of ushort.max with default id 65501
class UShortArrayPacket : IPacket
{
	mixin CommonArrayPacket!(ushort, 65501);
}

/// Length prefixed short[] packet with maximum length of ushort.max with default id 65502
class ShortArrayPacket : IPacket
{
	mixin CommonArrayPacket!(short, 65502);
}

/// Length prefixed uint[] packet with maximum length of ushort.max with default id 65503
class UIntArrayPacket : IPacket
{
	mixin CommonArrayPacket!(uint, 65503);
}

/// Length prefixed int[] packet with maximum length of ushort.max with default id 65504
class IntArrayPacket : IPacket
{
	mixin CommonArrayPacket!(int, 65504);
}

/// Length prefixed ulong[] packet with maximum length of ushort.max with default id 65505
class ULongArrayPacket : IPacket
{
	mixin CommonArrayPacket!(ulong, 65505);
}

/// Length prefixed long[] packet with maximum length of ushort.max with default id 65506
class LongArrayPacket : IPacket
{
	mixin CommonArrayPacket!(long, 65506);
}

/// Length prefixed float[] packet with maximum length of ushort.max with default id 65507
class FloatArrayPacket : IPacket
{
	mixin CommonArrayPacket!(float, 65507);
}

/// Length prefixed double[] packet with maximum length of ushort.max with default id 65508
class DoubleArrayPacket : IPacket
{
	mixin CommonArrayPacket!(double, 65508);
}