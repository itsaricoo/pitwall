import QtQuick 2.1
import qb.components 1.0

Tile {
	id: pitwallTile
	onClicked: stage.openFullscreen(app.screenUrl)

	property real sc: width / 200

	Text {
		id: tileRace
		anchors.horizontalCenter: parent.horizontalCenter
		y: Math.round(parent.height * 0.10)
		width: parent.width - Math.round(16 * pitwallTile.sc)
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
		text: app.tileRace
		font.family: qfont.bold.name
		font.pixelSize: Math.max(11, Math.round(18 * pitwallTile.sc))
		color: colors.tileTextColor
	}

	Rectangle {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: tileRace.bottom
		anchors.topMargin: Math.round(4 * pitwallTile.sc)
		width: Math.round(60 * pitwallTile.sc)
		height: Math.max(2, Math.round(3 * pitwallTile.sc))
		color: "#e10600"
	}

	Text {
		id: tileCountdown
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		anchors.verticalCenterOffset: Math.round(2 * pitwallTile.sc)
		width: parent.width - Math.round(12 * pitwallTile.sc)
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
		text: app.countdownText
		font.family: qfont.bold.name
		font.pixelSize: Math.max(11, Math.round(32 * pitwallTile.sc))
		color: colors.tileTextColor
	}

	Text {
		id: tileSession
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: tileCountdown.bottom
		anchors.topMargin: Math.round(2 * pitwallTile.sc)
		width: parent.width - Math.round(16 * pitwallTile.sc)
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
		text: app.sessionLabel
		font.family: qfont.regular.name
		font.pixelSize: Math.max(11, Math.round(16 * pitwallTile.sc))
		color: colors.tileTextColor
	}

	Text {
		id: tileLeader
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: Math.round(10 * pitwallTile.sc)
		width: parent.width - Math.round(16 * pitwallTile.sc)
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight
		visible: app.leaderText !== ""
		text: "P1 " + app.leaderText
		font.family: qfont.regular.name
		font.pixelSize: Math.max(11, Math.round(14 * pitwallTile.sc))
		color: colors.tileTextColor
	}
}
