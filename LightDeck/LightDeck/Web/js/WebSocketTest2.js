function WebSocketTest2()
{
	if ("WebSocket" in window)
	{
		var ws = new WebSocket("ws://localhost:51782/service");
		ws.onopen = function()
		{
			// Web Socket is connected
			alert("websocket is open");
			
			// You can send data now
			//ws.send("Hey man, you got the time?");
		};
		ws.onmessage = function(evt) { alert("received: " + evt.data); };
		ws.onclose = function() { alert("websocket is closed"); };
	}
	else
	{
		alert("Browser doesn't support WebSocket!");
	}
}