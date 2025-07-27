const client = mqtt.connect('ws://192.168.50.161:9001');

client.on('connect', function () {
    console.log('Connected to MQTT broker');
});

document.getElementById('startMotor').addEventListener('click', function() {
    client.publish('/1/toggle1', '1');
});

document.getElementById('stopMotor').addEventListener('click', function() {
    client.publish('/1/toggle1', '0');
});

document.getElementById('startCalibrating').addEventListener('click', function() {
    client.publish('/1/toggle2', '1');
});

document.getElementById('stopCalibrating').addEventListener('click', function() {
    client.publish('/1/toggle2', '0');
});