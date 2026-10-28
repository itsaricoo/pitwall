import QtQuick 2.1

Rectangle {
	id: switchRow

	property string label: ""
	property string hint: ""
	property bool checked: false
	property real sc: 1
	property real fsc: 1
	signal toggled()

	height: Math.round(58 * sc)
	radius: Math.round(6 * sc)
	color: "#f4f6f8"

	Text {
		id: labelText
		x: Math.round(16 * switchRow.sc)
		y: switchRow.hint !== "" ? Math.round(6 * switchRow.sc) : (parent.height - height) / 2
		width: parent.width - pitwallSwitch.width - Math.round(48 * switchRow.sc)
		elide: Text.ElideRight
		text: switchRow.label
		font.family: qfont.bold.name
		font.pixelSize: Math.max(12, Math.round(21 * switchRow.fsc))
		color: "#15151e"
	}

	Text {
		visible: switchRow.hint !== ""
		x: labelText.x
		anchors.top: labelText.bottom
		width: labelText.width
		elide: Text.ElideRight
		text: switchRow.hint
		font.family: qfont.regular.name
		font.pixelSize: Math.max(11, Math.round(15 * switchRow.fsc))
		color: "#777777"
	}

	PitwallSwitch {
		id: pitwallSwitch
		anchors.right: parent.right
		anchors.rightMargin: Math.round(16 * switchRow.sc)
		anchors.verticalCenter: parent.verticalCenter
		sc: switchRow.sc
		checked: switchRow.checked
		onToggled: switchRow.toggled()
	}
}
