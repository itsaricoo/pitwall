import QtQuick 2.1
import qb.components 1.0

Screen {
	id: pitwallSettingsScreen
	screenTitle: "Pitwall instellingen"

	property real sc: width / 1024
	property real fsc: sc * (width < 1000 ? 1.12 : 1)
	property int margin: Math.round(30 * sc)
	property int rowGap: Math.round(6 * sc)

	function fs(n) {
		return Math.max(11, Math.round(n * fsc));
	}

	Column {
		id: settingsColumn
		x: pitwallSettingsScreen.margin
		y: Math.round(14 * pitwallSettingsScreen.sc)
		width: pitwallSettingsScreen.width - 2 * pitwallSettingsScreen.margin
		spacing: pitwallSettingsScreen.rowGap

		PitwallSwitchRow {
			width: parent.width
			sc: pitwallSettingsScreen.sc
			fsc: pitwallSettingsScreen.fsc
			label: "Nederlandse namen"
			hint: "GP-namen, landen en uitvalredenen in het Nederlands"
			checked: app.dutchNames
			onToggled: {
				app.dutchNames = !app.dutchNames;
				app.saveSettings();
			}
		}

		PitwallSwitchRow {
			width: parent.width
			sc: pitwallSettingsScreen.sc
			fsc: pitwallSettingsScreen.fsc
			label: "Melding voor de race"
			checked: app.alertRace
			onToggled: {
				app.alertRace = !app.alertRace;
				app.saveSettings();
			}
		}

		PitwallSwitchRow {
			width: parent.width
			sc: pitwallSettingsScreen.sc
			fsc: pitwallSettingsScreen.fsc
			label: "Melding voor de kwalificatie"
			checked: app.alertQuali
			onToggled: {
				app.alertQuali = !app.alertQuali;
				app.saveSettings();
			}
		}

		PitwallSwitchRow {
			width: parent.width
			sc: pitwallSettingsScreen.sc
			fsc: pitwallSettingsScreen.fsc
			label: "Melding voor sprint en sprintkwalificatie"
			checked: app.alertSprint
			onToggled: {
				app.alertSprint = !app.alertSprint;
				app.saveSettings();
			}
		}

		PitwallSwitchRow {
			width: parent.width
			sc: pitwallSettingsScreen.sc
			fsc: pitwallSettingsScreen.fsc
			label: "Geluid bij melding"
			checked: app.alertSound
			onToggled: {
				app.alertSound = !app.alertSound;
				app.saveSettings();
			}
		}

		Rectangle {
			width: parent.width
			height: Math.round(66 * pitwallSettingsScreen.sc)
			radius: Math.round(6 * pitwallSettingsScreen.sc)
			color: "#f4f6f8"

			Text {
				x: Math.round(16 * pitwallSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				text: "Melding vooraf"
				font.family: qfont.bold.name
				font.pixelSize: pitwallSettingsScreen.fs(21)
				color: "#15151e"
			}

			StandardButton {
				id: leadMinus
				anchors.right: leadValue.left
				anchors.rightMargin: Math.round(8 * pitwallSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(70 * pitwallSettingsScreen.sc)
				height: Math.round(50 * pitwallSettingsScreen.sc)
				text: "-"
				onClicked: app.stepLead(-1)
			}

			Text {
				id: leadValue
				anchors.right: leadPlus.left
				anchors.rightMargin: Math.round(8 * pitwallSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(110 * pitwallSettingsScreen.sc)
				horizontalAlignment: Text.AlignHCenter
				text: app.alertLead + " min"
				font.family: qfont.bold.name
				font.pixelSize: pitwallSettingsScreen.fs(24)
				color: "#15151e"
			}

			StandardButton {
				id: leadPlus
				anchors.right: parent.right
				anchors.rightMargin: Math.round(16 * pitwallSettingsScreen.sc)
				anchors.verticalCenter: parent.verticalCenter
				width: Math.round(70 * pitwallSettingsScreen.sc)
				height: Math.round(50 * pitwallSettingsScreen.sc)
				text: "+"
				onClicked: app.stepLead(1)
			}
		}

		StandardButton {
			width: Math.round(300 * pitwallSettingsScreen.sc)
			height: Math.round(58 * pitwallSettingsScreen.sc)
			text: "Test melding"
			onClicked: app.testAlert()
		}
	}
}
