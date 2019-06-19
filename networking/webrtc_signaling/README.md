# A WebSocket signaling server/client for WebRTC.

This demo is devided in 4 parts:

- The `server` folder contains the signaling server implementation written in GDScript (so it can be run by a game server running Godot)
- The `server_node` folder contains the signaling server implementation written in Node.js (if you don't plan to run a game server but only match-making).
- The `client` part contains the client implementation in GDScript.
  - Itself divided into raw protocol and `WebRTCMultiplayer` handling.
- The `demo` contains a small app that uses it.

**NOTE**: You must extract the [latest version](https://github.com/godotengine/webrtc-native/releases) of the WebRTC GDNative plugin in the project folder to run from desktop.

## Protocol

The protocol is text based, and composed by a command and possibly multiple payload arguments, each separated by a new line.

Messages without payload must still end with a newline and are the following:
- `J: ` (or `J: <ROOM>`), must be sent by client immediately after connection to get a lobby assigned or join a known one.
  This messages is also sent by server back to the client to notify assigned lobby, or simply a successful join.
- `I: <ID>`, sent by server to identify the client when it joins a room.
- `N: <ID>`, sent by server to notify new peers in the same lobby.
- `D: <ID>`, sent by server to notify when a peer in the same lobby disconnects.
- `S: `, sent by client to seal the lobby (only the client that created it is allowed to seal a lobby).

When a lobby is sealed, no new client will be able to join, and the lobby will be destroyed (and clients disconnected) after 10 seconds.

Messages with payload (used to transfer WebRTC parameters) are:
- `O: <ID>`, used to send an offer.
- `A: <ID>`, used to send an answer.
- `C: <ID>`, used to send a candidate.

When sending the parameter, a client will set `<ID>` as the destination peer, the server will replace it with the id of the sending peer, and rely it to the proper destination.
