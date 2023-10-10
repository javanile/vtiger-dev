<?php


if (isset($_GET['test']) && $_GET['test'] == 'test') {
    echo <<<EOT
<html ng-app="app">
<head>
    <script type="text/javascript">
        var myWebSocket;
        function connectToWS() {
            var endpoint = document.getElementById("endpoint").value;
            if (myWebSocket !== undefined) {
                myWebSocket.close()
            }
            myWebSocket = new WebSocket(endpoint);

            myWebSocket.onmessage = function(event) {
                var leng;
                if (event.data.size === undefined) {
                    leng = event.data.length
                } else {
                    leng = event.data.size
                }
                console.log("onmessage. size: " + leng + ", content: " + event.data);
            }

            myWebSocket.onopen = function(evt) {
                console.log("onopen.");
            };

            myWebSocket.onclose = function(evt) {
                console.log("onclose.");
            };

            myWebSocket.onerror = function(evt) {
                console.log("Error!");
            };

            myWebSocket.addEventListener("error", (event) => {
                console.log("WebSocket error: ", event);
            });
        }

        function sendMsg() {
            var message = document.getElementById("myMessage").value;
            myWebSocket.send(message);
        }
        function closeConn() {
            myWebSocket.close();
        }
    </script>
</head>
<body>
<form>
    connection to: <input type="text" id="endpoint" name="endpoint" value="ws://localhost:8088/websocket-52000"  style="width: 200px" ><br>
</form>
<input type="button" onclick="connectToWS()" value="connect to WebSocket endpoint" /><br><br>
<form>
    message: <input type="text" id="myMessage" name="myMessage" value="hi there!"><br>
</form>
<input type="button" onclick="sendMsg()" value="Send message" />
<input type="button" onclick="closeConn()" value="Close connection" />
</body>
</html>
EOT;
    exit;
}


$host = $argv[1] ?? '0.0.0.0';
$port = $argv[2] ?? 52000;

define('WEBSOCKET_HOST', $host);
define('WEBSOCKET_PORT', $port);

class WebSocketServer
{
    function send($message) {
        global $clientSocketArray;
        $messageLength = strlen($message);
        foreach($clientSocketArray as $clientSocket)
        {
            @socket_write($clientSocket,$message,$messageLength);
        }
        return true;
    }

    function unseal($socketData) {
        $length = ord($socketData[1]) & 127;
        if($length == 126) {
            $masks = substr($socketData, 4, 4);
            $data = substr($socketData, 8);
        }
        elseif($length == 127) {
            $masks = substr($socketData, 10, 4);
            $data = substr($socketData, 14);
        }
        else {
            $masks = substr($socketData, 2, 4);
            $data = substr($socketData, 6);
        }
        $socketData = "";
        for ($i = 0; $i < strlen($data); ++$i) {
            $socketData .= $data[$i] ^ $masks[$i%4];
        }
        return $socketData;
    }

    function seal($socketData) {
        $b1 = 0x80 | (0x1 & 0x0f);
        $length = strlen($socketData);

        if($length <= 125)
            $header = pack('CC', $b1, $length);
        elseif($length > 125 && $length < 65536)
            $header = pack('CCn', $b1, 126, $length);
        elseif($length >= 65536)
            $header = pack('CCNN', $b1, 127, $length);
        return $header.$socketData;
    }

    function doHandshake($received_header,$client_socket_resource, $host_name, $port) {
        $headers = array();
        $lines = preg_split("/\r\n/", $received_header);
        foreach($lines as $line)
        {
            $line = chop($line);
            if(preg_match('/\A(\S+): (.*)\z/', $line, $matches))
            {
                $headers[$matches[1]] = $matches[2];
            }
        }

        $secKey = $headers['Sec-WebSocket-Key'];
        $secAccept = base64_encode(pack('H*', sha1($secKey . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')));
        $buffer  = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n" .
            "Upgrade: websocket\r\n" .
            "Connection: Upgrade\r\n" .
            "WebSocket-Origin: $host_name\r\n" .
            "WebSocket-Location: ws://$host_name:$port/demo/shout.php\r\n".
            "Sec-WebSocket-Accept:$secAccept\r\n\r\n";
        socket_write($client_socket_resource,$buffer,strlen($buffer));
    }

    function newConnectionACK($client_ip_address)
    {
        $message = 'New client ' . $client_ip_address.' joined';
        $messageArray = array('message'=>$message,'message_type'=>'chat-connection-ack');
        $ACK = $this->seal(json_encode($messageArray));
        return $ACK;
    }

    function connectionDisconnectACK($client_ip_address) {
        $message = 'Client ' . $client_ip_address.' disconnected';
        $messageArray = array('message'=>$message,'message_type'=>'chat-connection-ack');
        $ACK = $this->seal(json_encode($messageArray));
        return $ACK;
    }

    function createChatBoxMessage($chat_user,$chat_box_message) {
        $message = $chat_user . ": " . $chat_box_message . "\n";
        $messageArray = array('message'=>$message,'message_type'=>'chat-box-html');
        $chatMessage = $this->seal(json_encode($messageArray));
        return $chatMessage;
    }
}

$webSocketServer = new WebSocketServer();

$socketResource = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
socket_set_option($socketResource, SOL_SOCKET, SO_REUSEADDR, 1);
socket_bind($socketResource, 0, WEBSOCKET_PORT);
socket_listen($socketResource);

$null = null;
$clientSocketArray = array($socketResource);
while (true) {
    $newSocketArray = $clientSocketArray;
    socket_select($newSocketArray, $null, $null, 0, 10);

    if (in_array($socketResource, $newSocketArray)) {
        $newSocket = socket_accept($socketResource);
        $clientSocketArray[] = $newSocket;

        $header = socket_read($newSocket, 1024);
        $webSocketServer->doHandshake($header, $newSocket, WEBSOCKET_HOST, WEBSOCKET_PORT);

        socket_getpeername($newSocket, $client_ip_address);
        $connectionACK = $webSocketServer->newConnectionACK($client_ip_address);

        $webSocketServer->send($connectionACK);

        $newSocketIndex = array_search($socketResource, $newSocketArray);
        unset($newSocketArray[$newSocketIndex]);
    }

    foreach ($newSocketArray as $newSocketArrayResource) {
        while(socket_recv($newSocketArrayResource, $socketData, 1024, 0) >= 1){
            $socketMessage = $webSocketServer->unseal($socketData);
            $messageObj = json_decode($socketMessage);

            $chat_box_message = $webSocketServer->createChatBoxMessage($messageObj->chat_user, $messageObj->chat_message);
            $webSocketServer->send($chat_box_message);
            break 2;
        }

        $socketData = @socket_read($newSocketArrayResource, 1024, PHP_NORMAL_READ);
        if ($socketData === false) {
            socket_getpeername($newSocketArrayResource, $client_ip_address);
            $connectionACK = $webSocketServer->connectionDisconnectACK($client_ip_address);
            $webSocketServer->send($connectionACK);
            $newSocketIndex = array_search($newSocketArrayResource, $clientSocketArray);
            unset($clientSocketArray[$newSocketIndex]);
        }
    }
}

socket_close($socketResource);
