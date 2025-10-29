import QtQuick 2.15

Item {
    id: root
    property real hue: 0.0
    property real saturation: 1.0

ShaderEffect {
    id: shaderEffect
    anchors.fill: parent
    fragmentShader: "shaders/ColorWheel.frag.qsb"
        onStatusChanged: if (status === ShaderEffect.Error) console.log("Shader error:", log)
}

    // Picker indicator
    Rectangle {
        width: 10
        height: 10
        radius: 5
        color: "white"
        border.color: "black"
        border.width: 1
        x: (root.width / 2) + (root.width / 2 * root.saturation * Math.cos(2 * Math.PI * root.hue)) - width / 2
        y: (root.height / 2) + (root.height / 2 * root.saturation * Math.sin(2 * Math.PI * root.hue)) - height / 2
    }

    MouseArea {
      anchors.fill: parent
      onPressed: update(mouse)
      onPositionChanged: update(mouse)

      function update(mouse) {
          let dx = mouse.x - width / 2
          let dy = mouse.y - height / 2
          let r = Math.sqrt(dx*dx + dy*dy) / (width / 2)
          if (r > 1.0) return
          let a = Math.atan2(dy, dx) / (2 * Math.PI)
          if (a < 0) a += 1.0
          root.updateHue(a)
          root.updateSaturation(r)
      }
  }
}