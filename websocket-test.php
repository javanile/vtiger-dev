<?php
// Abilita l'output compresso (se necessario)
if (function_exists('ob_gzhandler')) {
    ob_start('ob_gzhandler');
} else {
    ob_start();
}

// Imposta l'intestazione per indicare che è una connessione WebSocket
header('Upgrade: websocket');
header('Connection: Upgrade');
header('Sec-WebSocket-Accept: ' . base64_encode(hash('sha1', $_SERVER['HTTP_SEC_WEBSOCKET_KEY'] . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11', true)));
header('Sec-WebSocket-Protocol: chat');

// Apre la connessione WebSocket
$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
socket_bind($socket, '0.0.0.0', 80); // Modifica la porta e l'indirizzo IP se necessario
socket_listen($socket);

// Accetta la connessione WebSocket
$client = socket_accept($socket);

// Leggi i dati inviati dal client WebSocket
$data = socket_read($client, 2048);

// Decodifica i dati WebSocket
$decoded_data = decodeWebSocketData($data);

// Esegui le operazioni necessarie con i dati

// Codifica i dati di risposta WebSocket
$response = encodeWebSocketData('Hello, WebSocket Client!');

// Invia la risposta al client WebSocket
socket_write($client, $response, strlen($response));

// Chiudi la connessione WebSocket
socket_close($client);

// Funzione per decodificare i dati WebSocket
function decodeWebSocketData($data) {
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
    $decoded = '';
    for ($i = 0; $i < strlen($data); ++$i) {
        $decoded .= $data[$i] ^ $masks[$i % 4];
    }
    return $decoded;
}

// Funzione per codificare i dati WebSocket
function encodeWebSocketData($data) {
    $length = strlen($data);
    if ($length <= 125) {
        return "\x81" . chr($length) . $data;
    } elseif ($length <= 65535) {
        return "\x81" . chr(126) . pack('n', $length) . $data;
    } else {
        return "\x81" . chr(127) . pack('xxxxN', $length) . $data;
    }
}
