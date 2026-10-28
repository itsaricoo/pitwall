import QtQuick 2.1

Rectangle {
	id: pitwallRow

	property string pos: ""
	property string name: ""
	property string sub: ""
	property string value: ""
	property string stripe: ""            // teamkleur, leeg = geen streep
	property real sc: 1                   // schaal voor afmetingen
	property real fsc: 1                  // schaal voor lettergrootte
	property bool alt: false
	property bool hl: false               // gemarkeerd (bijv. volgende race)
	property bool muted: false            // vervaagd (bijv. gereden race)
	property bool podiumOn: true
	property bool podium: podiumOn && (pos === "1" || pos === "2" || pos === "3")

	radius: Math.round(5 * sc)
	color: hl ? "#fde4e2" : (alt ? "#eef1f4" : "#f8f9fa")

	// Teamkleur
	Rectangle {
		visible: pitwallRow.stripe !== ""
		x: 0
		width: Math.max(4, Math.round(7 * pitwallRow.sc))
		height: parent.height
		radius: pitwallRow.radius
		color: pitwallRow.stripe !== "" ? pitwallRow.stripe : "transparent"
	}

	Text {
		id: posText
		x: Math.round(10 * pitwallRow.sc)
		width: Math.round(34 * pitwallRow.sc)
		height: parent.height
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		text: pitwallRow.pos
		font.family: qfont.bold.name
		font.pixelSize: Math.max(11, Math.round(18 * pitwallRow.fsc))
		color: pitwallRow.muted ? "#999999" : (pitwallRow.podium ? "#e10600" : "#555555")
	}

	Text {
		id: nameText
		x: Math.round(52 * pitwallRow.sc)
		width: Math.round(pitwallRow.width * 0.40)
		height: parent.height
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
		text: pitwallRow.name
		font.family: qfont.bold.name
		font.pixelSize: Math.max(11, Math.round(17 * pitwallRow.fsc))
		color: pitwallRow.muted ? "#999999" : "#15151e"
	}

	Text {
		id: valueText
		anchors.right: parent.right
		anchors.rightMargin: Math.round(10 * pitwallRow.sc)
		width: Math.round(pitwallRow.width * 0.22)
		height: parent.height
		horizontalAlignment: Text.AlignRight
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
		text: pitwallRow.value
		font.family: qfont.bold.name
		font.pixelSize: Math.max(11, Math.round(17 * pitwallRow.fsc))
		color: pitwallRow.muted ? "#999999" : "#15151e"
	}

	Text {
		id: subText
		x: nameText.x + nameText.width + Math.round(6 * pitwallRow.sc)
		width: valueText.x - x - Math.round(6 * pitwallRow.sc)
		height: parent.height
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
		text: pitwallRow.sub
		font.family: qfont.regular.name
		font.pixelSize: Math.max(11, Math.round(15 * pitwallRow.fsc))
		color: "#777777"
	}
}
