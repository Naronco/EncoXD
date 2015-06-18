module Enco.Shared.Network.Tcp;

import Enco.Shared.Network.Network;
import EncoShared;

class TcpSocket
{
	private std.socket.InternetAddress ipaddress;
	private std.socket.TcpSocket	   tcpsock;

	public this(std.socket.TcpSocket handle)
	{
		tcpsock = handle;
	}

	public this()
	{
		tcpsock = new std.socket.TcpSocket();
	}

	public bool bind(const string host)
	{
		i16	   port		= 0;
		string hostname = host;

		if (!host.contains(":"))
			return false;
		string[] splits = host.split(':');

		hostname = splits[0];

		if (!splits[1].isNumeric())
			return false;
		port = parse!i16(splits[1]);

		ipaddress = new std.socket.InternetAddress(hostname, port);
		return true;
	}

	public void bind(const string host, i16 fallbackPort)
	{
		i16	   port		= fallbackPort;
		string hostname = host;

		if (host.contains(":"))
		{
			string[] splits = host.split(':');

			hostname = splits[0];

			if (splits[1].isNumeric())
				port = parse!i16(splits[1]);
		}

		ipaddress = new std.socket.InternetAddress(hostname, port);
	}

	public void bind(u16 listenPort)
	{
		ipaddress = new std.socket.InternetAddress(listenPort);
	}

	public bool listen(i32 backlog)
	{
		tcpsock.bind(ipaddress);
		tcpsock.listen(backlog);
		return isAlive;
	}

	public bool connect()
	{
		tcpsock.connect(ipaddress);
		return isAlive;
	}

	public void disconnect()
	{
		tcpsock.shutdown(std.socket.SocketShutdown.BOTH);
		tcpsock.close();
		tcpsock = new std.socket.TcpSocket();
	}

	public TcpSocket accept()
	{
		return new TcpSocket(cast(std.socket.TcpSocket) (tcpsock.accept()));
	}

	public ptrdiff_t send(const(void)[] data)
	{
		return tcpsock.send(data);
	}

	public void[] receive(u32 len, out ptrdiff_t recieved)
	{
		void[] data = new void[len];
		recieved = tcpsock.receive(data);
		return data;
	}

	public void[] receive(u32 len)
	{
		void[] data = new void[len];
		tcpsock.receive(data);
		return data;
	}

	public ptrdiff_t send(IPacket packet)
	{
		void[] data;
		data[0 .. 0]			 = [packet.length];
		data[1 .. packet.length] = packet.serialize()[0 .. packet.length];
		return send(data);
	}

	public void receive(IPacket packet)
	{
		void[] lenBuf = receive(1);
		packet.deserialize(receive((cast(u32[]) lenBuf[0 .. 0])[0]));
	}

	public @property bool isAlive()
	{
		return tcpsock.isAlive;
	}
}
