module Client;

import EncoShared;

import std.bitmanip;
import std.socket;
import std.stdio;

import consoled;

import core.thread;

class Client
{
public:
	this(string ip, ushort port)
	{
		this.ip = ip;
		this.port = port;
	}

	void connect()
	{
		socket = new TcpSocket();
		socket.connect(new InternetAddress(ip, port));
		socket.blocking = false;

		ubyte[1024] buffer = new ubyte[1024];
		ubyte[] data;

		string line = "";

		writeln("Joined.");

		while (true)
		{
			int received;
			while ((received = socket.receive(buffer)) > 0)
			{
				data = buffer[0 .. received];
			}
			if (data.length > 0)
			{
				StringPacket msg = new StringPacket();
				msg.deserialize(data);
				drawHorizontalLine(ConsolePoint(0, cursorPos.y), width, ' ');
				setCursorPos(0, cursorPos.y);
				writeln(" >> ", msg.text);
				write(line);
			}

			if (kbhit())
			{
				line ~= getch();
				if (line.length > 0 && line[$ - 1] == '\n')
				{
					socket.send(nativeToBigEndian(StringPacket.PACKET_ID) ~new StringPacket(line[0 .. $ - 1]).serialize());
					line = "";
				}
				//drawHorizontalLine(ConsolePoint(0, cursorPos.y), width, ' ');
				setCursorPos(0, cursorPos.y);
				write(line);
				setCursorPos(line.length, cursorPos.y);
			}

			Thread.sleep(50.msecs);
		}
	}

	void disconnect()
	{
		socket.shutdown(SocketShutdown.BOTH);
		socket.close();
	}

	string ip;
	ushort port;
	TcpSocket socket;
}
