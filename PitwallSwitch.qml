import QtQuick 2.1

Item {
	id: pitwallSwitch

	property bool checked: false
	property real sc: 1
	signal toggled()

	width: Math.round(96 * sc)
	height: Math.round(48 * sc)

	Rectangle {
		anchors.fill: parent
		radius: height / 2
		color: pitwallSwitch.checked ? "#e10600" : "#c8cdd2"
	}

	Rectangle {
		width: parent.height - Math.round(8 * pitwallSwitch.sc)
		height: width
		radius: width / 2
		y: Math.round(4 * pitwallSwitch.sc)
		x: pitwallSwitch.checked ? parent.width - width - Math.round(4 * pitwallSwitch.sc) : Math.round(4 * pitwallSwitch.sc)
		color: "#ffffff"
	}

	Text {
		anchors.verticalCenter: parent.verticalCenter
		x: pitwallSwitch.checked ? Math.round(14 * pitwallSwitch.sc) : parent.width - width - Math.round(12 * pitwallSwitch.sc)
		text: pitwallSwitch.checked ? "Aan" : "Uit"
		font.family: qfont.bold.name
		font.pixelSize: Math.max(11, Math.round(16 * pitwallSwitch.sc))
		color: pitwallSwitch.checked ? "#ffffff" : "#555555"
	}

	MouseArea {
		anchors.fill: parent
		anchors.margins: -Math.round(8 * pitwallSwitch.sc)
		onClicked: pitwallSwitch.toggled()
	}
}
