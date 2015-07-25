module EncoShared.Network.AsyncSocket;

import std.socket;

import core.thread;

import EncoShared;

class AsyncTCPSocket
{
private:
	bool m_isAsyncListening = false;
	bool m_isAsyncReceiving = false;
	Duration m_sleepDur = 1.msecs;

	void acceptLoop()
	{
		m_base.blocking = true;
		try
		{
			while(m_base && m_base.isAlive)
			{
				auto socket = m_base.accept();
				if(socket !is null)
				{
					onConnection(this, new AsyncTCPSocket(cast(TcpSocket)socket));
				}
			}
		}
		catch(Exception e)
		{
			Logger.errln(e);
			onError(this, e);
		}
		m_isAsyncListening = false;
	}

	void receiveLoop()
	{
		m_base.blocking = false;

		ubyte[1024] packet = new ubyte[1024];
		try
		{
			while(m_base && m_base.isAlive())
			{
				ptrdiff_t length = m_base.receive(packet);

				if(length == 0)
				{
					onDisconnect(this);
					return;
				}
				else if(length > 0)
				{
					ubyte[] data = packet[0 .. length];
					while(length == 1024)
					{
						length = m_base.receive(packet);
						if(length > 0)
							data ~= packet[0 .. length];
					}
					onData(this, data);
				}

				Thread.sleep(m_sleepDur);
			}
		}
		catch(Exception e)
		{
			Logger.errln(e);
			onError(this, e);
		}
		m_isAsyncReceiving = false;
	}

public:
	this()
	{
		m_base = new TcpSocket();
	}

	this(TcpSocket socket)
	{
		m_base = socket;
	}

	void listenAsync(int backlog)
	{
		assert(!m_isAsyncReceiving, "Can not listen while receiving!");
		assert(!m_isAsyncListening, "Already listening!");
		m_isAsyncListening = true;
		m_base.listen(backlog);
		new Thread(&acceptLoop).start();
	}

	void receiveAsync()
	{
		assert(!m_isAsyncListening, "Can not receive while listening!");
		assert(!m_isAsyncReceiving, "Already receiving!");
		m_isAsyncReceiving = true;
		new Thread(&receiveLoop).start();
	}

	@property ref Duration receiveSleep()
	{
		return m_sleepDur;
	}

	@property ref TcpSocket handle()
	{
		return m_base;
	}

	Event!Exception onError = new Event!Exception;
	Event!AsyncTCPSocket onConnection = new Event!AsyncTCPSocket;
	Event!(ubyte[]) onData = new Event!(ubyte[])();
	Trigger onDisconnect = new Trigger;

	TcpSocket m_base;
	alias m_base this;
}