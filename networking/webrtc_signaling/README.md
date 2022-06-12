# A WebSocket signaling server/client for WebRTC.

This demo divided into 4 parts:

- The `server` folder contains the signaling server implementation written in GDScript (so it can be run by a game server running Godot)
- The `server_node` folder contains the signaling server implementation written in Node.js (in case you dont want to run a godot game server).
- The `client` folder contains the client implementation in GDScript.
  - It handles both the protocol and `WebRTCMultiplayer` separately.
- The `demo` contains a small app that uses it.

**NOTE**: You must extract the [latest version](https://github.com/godotengine/webrtc-native/releases) of the WebRTC GDNative plugin in the project folder to run on a desktop.

Language: GDScript

Renderer: GLES 2

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/537

## Protocol

The protocol is text based, which is composed of a command and possibly multiple payload arguments, each separated by a new line.

Messages without payload must still end with a newline and are the following:

- `J: ` (or `J: <ROOM>`), must be sent by the client immediately after connecting to get a lobby assigned or join a known one.
  These messages are from the server back to the client to notify the client of the assigned lobby, or simply of a successful join.
- `I: <ID>`, sent by the server to identify the client when it joins a room.
- `N: <ID>`, sent by the server to notify new peers in the same lobby.
- `D: <ID>`, sent by the server to notify when a peer in the same lobby disconnects.
- `S: `, sent by a client to seal the lobby (only the client that created it is allowed to seal a lobby).

When a lobby is sealed, new clients will be unable to join, and the lobby will be destroyed (and clients disconnected) after 10 seconds.

Messages with payload (used to transfer WebRTC parameters) are:

- `O: <ID>`, used to send an offer.
- `A: <ID>`, used to send an answer.
- `C: <ID>`, used to send a candidate.

When sending the parameter, a client will set `<ID>` as the destination peer, the server will replace it with the id of the sending peer, then relay it to the proper destination.

## Screenshots

![Screenshot](screenshots/screenshot.png)
