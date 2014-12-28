module Enco.Shared.Network.Tcp;

import Enco.Shared.Network.Network;
import EncoShared;

class TcpSocket
{
	private IPaddress ipaddress;
	private TCPsocket tcpsock;

	public this(TCPsocket handle)
	{
		tcpsock = handle;
	}

	public this()
	{
	}

	public bool bind(const string host)
	{
		i32 port = 0;
		string hostname = host;

		if(!host.contains(":"))
			return false;
		string[] splits = host.split(':');

		hostname = splits[0];

		if(!splits[1].isNumeric())
			return false;
		port = parse!int(splits[1]);
		
		return SDLNet_ResolveHost(&ipaddress, hostname.ptr, cast(u16)port) == 0;
	}

	public bool bind(const string host, i32 fallbackPort)
	{
		i32 port = fallbackPort;
		string hostname = host;

		if(host.contains(":"))
		{
			string[] splits = host.split(':');

			hostname = splits[0];

			if(splits[1].isNumeric())
				port = parse!int(splits[1]);
		}
		
		return SDLNet_ResolveHost(&ipaddress, hostname.ptr, cast(u16)port) == 0;
	}

	public bool bind(u16 listenPort)
	{
		return SDLNet_ResolveHost(&ipaddress, null, listenPort) == 0;
	}

	public bool connect()
	{
		tcpsock = SDLNet_TCP_Open(&ipaddress);
		return tcpsock != null;
	}

	public void disconnect()
	{
		SDLNet_TCP_Close(tcpsock);
	}

	public TcpSocket accept()
	{
		return new TcpSocket(SDLNet_TCP_Accept(tcpsock));
	}

	public bool send(void[] data)
	{
		return SDLNet_TCP_Send(tcpsock, data.ptr, data.length) >= data.length;
	}

	public byte[] recv(u32 length)
	{
		byte[] data;
		byte* buf;
		u32 left = length;
		u32 n;
		while(left > 0)
		{
			n = SDLNet_TCP_Recv(tcpsock, buf, left);
			if(n == -1)
				break;
			left -= n;
			data ~= buf[0 .. n];
		}
		assert(n != -1);
		return data;
	}

	public bool send(IPacket packet)
	{
		byte[] data = new byte[packet.length + u32.sizeof];
		u32 len = packet.length;
		data[0] = cast(byte)((len) & 0xFF);
		data[1] = cast(byte)((len >> 8) & 0xFF);
		data[2] = cast(byte)((len >> 16) & 0xFF);
		data[3] = cast(byte)((len >> 24) & 0xFF);
		data[4 .. $] = packet.serialize();
		return send(data);
	}

	public void recv(IPacket packet)
	{
		byte[] lenBuf = recv(4);
		int len = lenBuf[0] | (lenBuf[1] << 8) | (lenBuf[2] << 16) | (lenBuf[3] << 24);
		packet.deserialize(recv(len));
	}
}