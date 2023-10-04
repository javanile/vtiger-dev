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
    connection to: <input type="text" id="endpoint" name="endpoint" value="ws://localhost:8080/websocket-test.php"  style="width: 200px" ><br>
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

// Verifica se è stata ricevuta una richiesta WebSocket
if (isset($_SERVER['HTTP_CONNECTION']) && strtolower($_SERVER['HTTP_CONNECTION']) == 'upgrade' &&
    isset($_SERVER['HTTP_UPGRADE']) && strtolower($_SERVER['HTTP_UPGRADE']) == 'websocket' &&
    isset($_SERVER['HTTP_SEC_WEBSOCKET_KEY'])) {

    // Accetta la connessione WebSocket
    header('Connection: Upgrade');
    header('Upgrade: websocket');

    // Calcola la chiave di accettazione SHA-1
    $key = $_SERVER['HTTP_SEC_WEBSOCKET_KEY'];
    $acceptKey = base64_encode(pack('H*', sha1($key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')));

    // Invia l'intestazione di conferma WebSocket
    header('Sec-WebSocket-Accept: ' . $acceptKey);

    // Imposta il buffer di output su non bufferizzato
    ob_implicit_flush(true);

    // Leggi i dati WebSocket
    while (true) {
        $message = websocket_read();
        if ($message === false) {
            break; // Connessione chiusa
        }

        // Esegui l'elaborazione del messaggio
        $response = "Hai inviato: " . $message;

        // Invia una risposta WebSocket
        websocket_write($response);
    }
}

function websocket_read() {
    $data = fread(STDIN, 8192);
    if ($data === false || feof(STDIN)) {
        return false;
    }

    $length = ord($data[1]) & 127;
    if ($length == 126) {
        $masks = substr($data, 4, 4);
        $data = substr($data, 8);
    } elseif ($length == 127) {
        $masks = substr($data, 10, 4);
        $data = substr($data, 14);
    } else {
        $masks = substr($data, 2, 4);
        $data = substr($data, 6);
    }

    $message = '';
    for ($i = 0; $i < strlen($data); $i++) {
        $message .= $data[$i] ^ $masks[$i % 4];
    }

    return $message;
}

function websocket_write($data) {
    $length = strlen($data);

    if ($length <= 125) {
        fwrite(STDOUT, "\x81" . chr($length) . $data);
    } elseif ($length <= 65535) {
        fwrite(STDOUT, "\x81\x7E" . pack("n", $length) . $data);
    } else {
        fwrite(STDOUT, "\x81\x7F" . pack("NN", 0, $length) . $data);
    }
}
