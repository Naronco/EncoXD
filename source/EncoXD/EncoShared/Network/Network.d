module EncoShared.Network.Network;

import std.bitmanip;

import EncoShared;

import std.socket;

///
interface IPacket
{
	@property ushort id();
	/// Serializes the content without id. Streams should be Big Endian.
	ubyte[] serialize();
	/// Deserializes the content without id and advances the stream. Streams should be Big Endian.
	void deserialize(ref ubyte[] stream);
}

void writePacket(Socket socket, IPacket packet)
{

}