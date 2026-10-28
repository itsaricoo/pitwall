import QtQuick 2.1

Item {
	id: pitwallTable

	property variant rows: []
	property int cols: 2
	property real sc: 1
	property real fsc: 1
	property int rowH: Math.round(34 * sc)
	property int gap: Math.round(20 * sc)
	property int perCol: cols > 1 ? Math.max(1, Math.ceil(rows.length / cols)) : Math.max(1, rows.length)
	property int colW: Math.floor((width - (cols - 1) * gap) / cols)

	Repeater {
		model: pitwallTable.rows

		PitwallRow {
			x: Math.floor(index / pitwallTable.perCol) * (pitwallTable.colW + pitwallTable.gap)
			y: (index % pitwallTable.perCol) * pitwallTable.rowH
			width: pitwallTable.colW
			height: pitwallTable.rowH - Math.round(3 * pitwallTable.sc)
			sc: pitwallTable.sc
			fsc: pitwallTable.fsc
			alt: index % 2 === 1
			pos: modelData.pos
			name: modelData.name
			sub: modelData.sub
			value: modelData.value
			stripe: modelData.color ? modelData.color : ""
			hl: modelData.hl === true
			muted: modelData.muted === true
			podiumOn: modelData.plain !== true
		}
	}
}
