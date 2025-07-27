# Panorama Viewer

This project displays a 360-degree panoramic image within a 3D environment. It uses Processing for the visualization and provides a web-based interface to control motor and calibration functions via MQTT.

## Description

The core of the project is a Processing sketch that loads a panoramic image and textures it onto the inside of a cube. This creates an immersive experience, allowing the user to look around the panoramic scene. The project also includes a simple HTML page with JavaScript that acts as a remote control. This interface sends commands to the Processing sketch using the MQTT messaging protocol to control a motor and a calibration sequence.

## Prerequisites

To run this project, you will need:

*   [Processing](https://processing.org/download)
*   An MQTT broker (the sketch is configured to connect to `ws://192.168.50.161:9001`)
*   A web browser

## Running the Project

1.  **Start the MQTT Broker:** Ensure your MQTT broker is running and accessible.
2.  **Run the Processing Sketch:** Open the `panorama3.pde` file in the Processing IDE and run it.
3.  **Open the Web Interface:** Open the `index.html` file in a web browser.

## Controls

### Panorama View (Processing Window)

*   **Mouse Drag:** Click and drag the mouse to rotate the view inside the panorama.
*   **Arrow Keys (Up/Down):** Adjust the field of view (zoom in/out).
*   **Arrow Keys (Left/Right):** These keys seem to be intended to start and stop an automated rotation sequence, but the full implementation may not be present.

### Web Interface (`index.html`)

*   **Start Motor/Stop Motor:** Sends MQTT messages to toggle the motor on and off.
*   **Start Calibrating/Stop Calibrating:** Sends MQTT messages to start and stop the calibration process.

## Files

*   `panorama3.pde`: The main Processing sketch for the panorama viewer.
*   `index.html`: The web interface for controlling the motor and calibration.
*   `app.js`: The JavaScript code for the web interface, handling MQTT communication.
*   `data/`: This directory should contain the panoramic image file (`Panorama3.JPG`).
