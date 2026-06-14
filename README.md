# Panorama Viewer

A 360-degree panoramic image viewer built with Processing, plus a web-based remote control panel that communicates over MQTT. The viewer places you inside a textured cube so you can look around a panoramic scene, while the web UI sends commands to start/stop a motor and run a calibration sequence.

## Features

- Immersive panorama viewing inside a 3D cube (OPENGL renderer)
- Mouse-driven look-around and keyboard zoom
- Scripted 180° auto-rotation over 10 seconds
- MQTT remote control from any web browser on the same network
- Optional serial hardware integration (stubbed, ready to wire up)

## Architecture

```
┌─────────────┐     WebSocket      ┌──────────────┐      TCP       ┌─────────────────┐
│  index.html │ ──────────────────► │  MQTT Broker │ ◄──────────── │  panorama3.pde  │
│   + app.js  │   ws://host:9001   │  (Mosquitto) │  tcp://host:   │  (Processing)   │
└─────────────┘                    └──────────────┘     1883        └─────────────────┘
                                                                          │
                                                                          ▼ (optional)
                                                                   ┌──────────────┐
                                                                   │ Arduino/motor │
                                                                   └──────────────┘
```

The web interface publishes MQTT messages. The Processing sketch subscribes to the same topics and reacts by calling `fireSignal()`, which is intended to forward single-character commands over a serial port to attached hardware.

## Prerequisites

- [Processing](https://processing.org/download) (3.x or 4.x)
- [MQTT library for Processing](https://github.com/p5p/mqtt) — install via **Sketch → Import Library → Add Library**, then search for "MQTT"
- An MQTT broker with both TCP and WebSocket listeners (e.g. [Mosquitto](https://mosquitto.org/))
- A modern web browser

## Configuration

Both the Processing sketch and the web UI connect to a hardcoded broker address. Update these before running if your broker is elsewhere:

| File | Setting |
|------|---------|
| `panorama3.pde` (line 66) | `client.connect("tcp://192.168.50.161:1883", ...)` |
| `app.js` (line 1) | `mqtt.connect('ws://192.168.50.161:9001')` |

Your MQTT broker must expose:

- **Port 1883** — TCP, for the Processing client
- **Port 9001** — WebSocket, for the browser client

## Running the Project

1. **Start the MQTT broker** and confirm both TCP and WebSocket ports are reachable from your machine.
2. **Install the MQTT library** in Processing if you have not already.
3. **Open `panorama3.pde`** in the Processing IDE and click Run. The sketch loads `data/Panorama3.JPG` automatically.
4. **Open `index.html`** in a web browser (double-click or serve it locally). Check the browser console for `Connected to MQTT broker`.

## Controls

### Panorama Viewer (Processing window)

| Input | Action |
|-------|--------|
| Mouse drag | Rotate the view (look around) |
| ↑ / ↓ arrow keys | Zoom in / out (adjust field of view) |
| ← arrow key | Toggle scripted auto-rotation (180° over 10 seconds) |
| → arrow key | Toggles `rightPressed` flag (no handler implemented yet) |

### Web Interface (`index.html`)

| Button | MQTT topic | Payload |
|--------|------------|---------|
| Start Motor | `/1/toggle1` | `1` |
| Stop Motor | `/1/toggle1` | `0` |
| Start Calibrating | `/1/toggle2` | `1` |
| Stop Calibrating | `/1/toggle2` | `0` |

When the Processing sketch receives these messages, it calls `fireSignal()` with the corresponding character:

| Signal | Trigger |
|--------|---------|
| `s` | Motor start / scripted rotation start |
| `e` | Motor stop / scripted rotation end |
| `c` | Start calibrating |
| `a` | Stop calibrating |

## Hardware Integration

Serial communication with an Arduino or motor controller is prepared but currently disabled. To enable it:

1. Uncomment the `processing.serial.*` import and the `Serial` setup in `panorama3.pde`.
2. Implement `fireSignal()` to write the character to the serial port:

```java
void fireSignal(char c) {
  port.write(c);
}
```

## Panoramic Images

The sketch loads `data/Panorama3.JPG` (2048 × 256). Additional higher-resolution panoramas are included for reference or swapping:

| File | Dimensions |
|------|------------|
| `Panorama3.JPG` | 2048 × 256 (active) |
| `Panorama 2.JPG` | 8192 × 1025 |
| `Panorama 1.JPG` | 20875 × 2613 |

To use a different image, place it in `data/` and change the `loadImage()` call in `setup()`.

The panorama is mapped onto four cube walls (front, back, left, right) using UV texture coordinates, based on Dave Bollinger's [TexturedCube](https://processing.org/examples/texturedcube.html) example. Top and bottom faces are omitted.

## Project Structure

```
panorama/
├── panorama3.pde   # Main Processing sketch (viewer + MQTT subscriber)
├── index.html      # Web remote control UI
├── app.js          # MQTT publisher for the web UI
├── data/           # Panoramic JPEG assets
│   └── Panorama3.JPG
├── LICENSE         # GNU GPL v3
└── README.md
```

## License

This project is licensed under the [GNU General Public License v3](LICENSE).