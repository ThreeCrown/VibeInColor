import QtQuick 2.15

Item {
    id: root
    property real hue: 0.0
    property real saturation: 1.0

ShaderEffect {
    anchors.fill: parent
    fragmentShader: `
        #version 440

        layout(location = 0) in vec2 qt_TexCoord0;
        layout(location = 0) out vec4 fragColor;

        layout(std140, binding = 0) uniform buf {
            mat4 qt_Matrix;
            float qt_Opacity;
        } ubuf;

        vec4 hsv2rgb(vec4 c) {
            vec3 rgb = clamp(abs(mod(c.x*6.0 + vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
            return vec4(c.z * mix(vec3(1.0), rgb, c.y), c.w);
        }

        void main() {
            vec2 p = qt_TexCoord0 * 2.0 - 1.0;
            float r = length(p);
            float a = atan(p.y, p.x) / (3.1415926535 * 2.0) + 0.5;
            if (r <= 1.0) {
                fragColor = hsv2rgb(vec4(a, r, 1.0, ubuf.qt_Opacity));
            } else {
                fragColor = vec4(0.0, 0.0, 0.0, 0.0);
            }
        }`
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