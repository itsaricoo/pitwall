import QtQuick 2.1
import qb.components 1.0

Screen {
	id: pitwallAlertScreen
	screenTitle: "Pitwall"

	property real sc: width / 1024
	property real fsc: sc * (width < 1000 ? 1.12 : 1)

	function fs(n) {
		return Math.max(12, Math.round(n * fsc));
	}

	onShown: {
		autoClose.restart();
		app.startSound();
	}

	onHidden: {
		autoClose.stop();
		app.alertClosed();
	}

	// Sluit zichzelf na 90 seconden
	Timer {
		id: autoClose
		interval: 90000
		repeat: false
		running: false
		onTriggered: stage.navigateBack()
	}

	Rectangle {
		anchors.fill: parent
		color: "#15151e"
	}

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		height: Math.round(14 * pitwallAlertScreen.sc)
		color: "#e10600"
	}

	Text {
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(50 * pitwallAlertScreen.sc)
		text: "FORMULE 1"
		font.family: qfont.bold.name
		font.pixelSize: pitwallAlertScreen.fs(24)
		color: "#e10600"
	}

	Text {
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(100 * pitwallAlertScreen.sc)
		width: parent.width - Math.round(80 * pitwallAlertScreen.sc)
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
		text: app.alertTitle
		font.family: qfont.bold.name
		font.pixelSize: pitwallAlertScreen.fs(80)
		color: "#ffffff"
	}

	Text {
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(230 * pitwallAlertScreen.sc)
		width: parent.width - Math.round(80 * pitwallAlertScreen.sc)
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		text: app.alertText
		font.family: qfont.regular.name
		font.pixelSize: pitwallAlertScreen.fs(36)
		color: "#ffffff"
	}

	StandardButton {
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(390 * pitwallAlertScreen.sc)
		width: Math.round(360 * pitwallAlertScreen.sc)
		height: Math.round(90 * pitwallAlertScreen.sc)
		text: "Sluiten"
		onClicked: stage.navigateBack()
	}
}
