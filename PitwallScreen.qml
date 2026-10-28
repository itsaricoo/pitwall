import QtQuick 2.1
import qb.components 1.0

Screen {
	id: pitwallScreen
	screenTitle: "Pitwall"

	// Ontworpen op 1024x600 (Toon 2), schaalt mee naar 800x480 (Toon 1)
	property real sc: width / 1024
	property real fsc: sc * (width < 1000 ? 1.12 : 1)       // lettertjes iets groter op Toon 1
	property int margin: Math.round(20 * sc)
	property int tab: 0
	property variant tabNames: ["Volgende", "Coureurs", "Teams", "Uitslag", "Kalender"]
	property int contentY: Math.round(112 * sc)

	function fs(n) {
		return Math.max(11, Math.round(n * fsc));
	}

	onShown: {
		addCustomTopRightButton("Instellingen");
		tab = 0;
		app.updateCountdown();
		app.refreshIfStale();
	}

	onCustomButtonClicked: stage.openFullscreen(app.settingsScreenUrl)

	function tableTitle(t, dutch) {
		if (t === 1)
			return "Coureurskampioenschap " + app.season;
		if (t === 2)
			return "Constructeurskampioenschap " + app.season;
		if (t === 3)
			return app.resultRaw !== "" ? "Uitslag " + app.gpName(app.resultRaw) : "Laatste race";
		if (t === 4)
			return "Kalender " + app.season;
		return "";
	}

	// Maakt de rijen voor tabblad 1 t/m 4 (de namen volgen de instelling)
	function buildRows(t, dutch, nowTs) {
		var out = [];
		var i;
		if (t === 1)
			return app.driverRows;
		if (t === 2)
			return app.constructorRows;
		if (t === 3) {
			for (i = 0; i < app.resultRows.length; i++) {
				var r = app.resultRows[i];
				out.push({
					pos: r.pos,
					name: r.name,
					sub: r.sub,
					value: r.isStatus ? app.statusName(r.value) : r.value,
					color: r.color
				});
			}
			return out;
		}
		if (t === 4) {
			var nextRound = (app.race && !app.race.none) ? app.race.round : "";
			var now = new Date().getTime();
			for (i = 0; i < app.calendar.length; i++) {
				var c = app.calendar[i];
				out.push({
					pos: c.round,
					name: app.gpName(c.raw),
					sub: c.locality,
					value: app.fmtDate(c.ts),
					plain: true,
					hl: c.round === nextRound,
					muted: c.ts < now && c.round !== nextRound
				});
			}
			return out;
		}
		return out;
	}

	// ---------- Tabbladen ----------
	Row {
		id: tabBar
		x: pitwallScreen.margin
		y: Math.round(10 * pitwallScreen.sc)
		spacing: Math.round(8 * pitwallScreen.sc)

		property int refreshW: Math.round(130 * pitwallScreen.sc)
		property int tabW: Math.floor((pitwallScreen.width - 2 * pitwallScreen.margin - 5 * spacing - refreshW) / 5)

		Repeater {
			model: pitwallScreen.tabNames

			Rectangle {
				width: tabBar.tabW
				height: Math.round(54 * pitwallScreen.sc)
				radius: Math.round(8 * pitwallScreen.sc)
				color: pitwallScreen.tab === index ? "#e10600" : "#e8eef2"

				Text {
					anchors.fill: parent
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					elide: Text.ElideRight
					text: modelData
					font.family: qfont.bold.name
					font.pixelSize: pitwallScreen.fs(20)
					color: pitwallScreen.tab === index ? "#ffffff" : "#333333"
				}

				MouseArea {
					anchors.fill: parent
					onClicked: pitwallScreen.tab = index
				}
			}
		}

		StandardButton {
			width: tabBar.refreshW
			height: Math.round(54 * pitwallScreen.sc)
			text: "Ververs"
			onClicked: app.refresh()
		}
	}

	// ---------- Titelregel + status ----------
	Text {
		id: titleLine
		x: pitwallScreen.margin
		y: Math.round(76 * pitwallScreen.sc)
		visible: pitwallScreen.tab > 0
		text: pitwallScreen.tableTitle(pitwallScreen.tab, app.dutchNames)
		font.family: qfont.bold.name
		font.pixelSize: pitwallScreen.fs(22)
		color: "#15151e"
	}

	Text {
		id: statusLine
		anchors.right: parent.right
		anchors.rightMargin: pitwallScreen.margin
		y: Math.round(80 * pitwallScreen.sc)
		text: app.statusText
		font.family: qfont.regular.name
		font.pixelSize: pitwallScreen.fs(16)
		color: "#777777"
	}

	// ---------- Tab 0: volgende race ----------
	Item {
		id: nextTab
		visible: pitwallScreen.tab === 0
		x: pitwallScreen.margin
		y: Math.round(106 * pitwallScreen.sc)
		width: parent.width - 2 * pitwallScreen.margin
		height: Math.round(380 * pitwallScreen.sc)

		property bool hasRace: app.race !== null && app.race !== undefined && !app.race.none

		Text {
			visible: !nextTab.hasRace
			width: parent.width
			y: Math.round(40 * pitwallScreen.sc)
			wrapMode: Text.WordWrap
			text: (app.race && app.race.none) ? "Het seizoen is afgelopen. Tot volgend jaar!" : "Gegevens laden..."
			font.family: qfont.regular.name
			font.pixelSize: pitwallScreen.fs(26)
			color: "#777777"
		}

		Item {
			id: raceInfo
			visible: nextTab.hasRace
			width: Math.round(570 * pitwallScreen.sc)
			height: parent.height

			Text {
				id: raceName
				width: parent.width
				elide: Text.ElideRight
				text: nextTab.hasRace ? app.gpName(app.race.raw) : ""
				font.family: qfont.bold.name
				font.pixelSize: pitwallScreen.fs(40)
				color: "#15151e"
			}

			Text {
				id: raceCircuit
				anchors.top: raceName.bottom
				anchors.topMargin: Math.round(2 * pitwallScreen.sc)
				width: parent.width
				elide: Text.ElideRight
				text: nextTab.hasRace ? app.race.circuit + " - " + app.placeText(app.race.locality, app.race.country) : ""
				font.family: qfont.regular.name
				font.pixelSize: pitwallScreen.fs(20)
				color: "#555555"
			}

			Column {
				id: sessionList
				anchors.top: raceCircuit.bottom
				anchors.topMargin: Math.round(16 * pitwallScreen.sc)
				width: parent.width
				spacing: Math.round(4 * pitwallScreen.sc)

				Repeater {
					model: nextTab.hasRace ? app.race.sessions : []

					Rectangle {
						property bool isNext: modelData.ts === app.nextTs
						property bool isPast: modelData.ts < app.nowTs

						width: sessionList.width
						height: Math.round(40 * pitwallScreen.sc)
						radius: Math.round(6 * pitwallScreen.sc)
						color: isNext ? "#fde4e2" : "#f4f6f8"

						Text {
							x: Math.round(14 * pitwallScreen.sc)
							height: parent.height
							verticalAlignment: Text.AlignVCenter
							text: modelData.label
							font.family: parent.isNext ? qfont.bold.name : qfont.regular.name
							font.pixelSize: pitwallScreen.fs(20)
							color: parent.isPast ? "#999999" : (parent.isNext ? "#e10600" : "#15151e")
						}

						Text {
							anchors.right: parent.right
							anchors.rightMargin: Math.round(14 * pitwallScreen.sc)
							height: parent.height
							verticalAlignment: Text.AlignVCenter
							text: app.fmtWhen(modelData.ts)
							font.family: parent.isNext ? qfont.bold.name : qfont.regular.name
							font.pixelSize: pitwallScreen.fs(20)
							color: parent.isPast ? "#999999" : (parent.isNext ? "#e10600" : "#15151e")
						}
					}
				}
			}
		}

		Rectangle {
			id: countdownCard
			visible: nextTab.hasRace
			x: Math.round(600 * pitwallScreen.sc)
			width: parent.width - x
			height: Math.round(230 * pitwallScreen.sc)
			radius: Math.round(10 * pitwallScreen.sc)
			color: "#15151e"

			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				y: Math.round(22 * pitwallScreen.sc)
				width: parent.width - Math.round(20 * pitwallScreen.sc)
				horizontalAlignment: Text.AlignHCenter
				elide: Text.ElideRight
				text: app.sessionLabel
				font.family: qfont.regular.name
				font.pixelSize: pitwallScreen.fs(24)
				color: "#ffffff"
			}

			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				anchors.verticalCenterOffset: Math.round(6 * pitwallScreen.sc)
				width: parent.width - Math.round(20 * pitwallScreen.sc)
				horizontalAlignment: Text.AlignHCenter
				elide: Text.ElideRight
				text: app.countdownText
				font.family: qfont.bold.name
				font.pixelSize: pitwallScreen.fs(52)
				color: "#ffffff"
			}

			Rectangle {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				anchors.bottomMargin: Math.round(46 * pitwallScreen.sc)
				width: Math.round(80 * pitwallScreen.sc)
				height: Math.max(2, Math.round(4 * pitwallScreen.sc))
				color: "#e10600"
			}

			Text {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				anchors.bottomMargin: Math.round(14 * pitwallScreen.sc)
				text: nextTab.hasRace ? "Ronde " + app.race.round + " - lokale tijd" : ""
				font.family: qfont.regular.name
				font.pixelSize: pitwallScreen.fs(18)
				color: "#bbbbbb"
			}
		}
	}

	// ---------- Tab 1-4: tabellen ----------
	PitwallTable {
		id: standingsTable
		visible: pitwallScreen.tab > 0
		x: pitwallScreen.margin
		y: pitwallScreen.contentY
		width: pitwallScreen.tab === 2 ? Math.round(700 * pitwallScreen.sc) : pitwallScreen.width - 2 * pitwallScreen.margin
		height: Math.round(380 * pitwallScreen.sc)
		sc: pitwallScreen.sc
		fsc: pitwallScreen.fsc
		cols: pitwallScreen.tab === 2 ? 1 : 2
		rowH: Math.round((pitwallScreen.tab === 4 ? 31 : 34) * pitwallScreen.sc)
		rows: pitwallScreen.buildRows(pitwallScreen.tab, app.dutchNames, pitwallScreen.tab === 4 ? app.nowTs : 0)
	}

	Text {
		visible: pitwallScreen.tab > 0 && standingsTable.rows.length === 0
		x: pitwallScreen.margin
		y: pitwallScreen.contentY
		text: "Nog geen gegevens beschikbaar."
		font.family: qfont.regular.name
		font.pixelSize: pitwallScreen.fs(22)
		color: "#777777"
	}
}
