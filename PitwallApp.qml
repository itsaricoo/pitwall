import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
	id: pitwallApp

	property url tileUrl: "PitwallTile.qml"
	property url screenUrl: "PitwallScreen.qml"
	property url settingsScreenUrl: "PitwallSettingsScreen.qml"
	property url alertScreenUrl: "PitwallAlertScreen.qml"
	property url thumbnailIcon: "drawables/pitwall.png"

	property PitwallTile pitwallTile
	property PitwallScreen pitwallScreen
	property PitwallSettingsScreen pitwallSettingsScreen
	property PitwallAlertScreen pitwallAlertScreen

	// Jolpica = open opvolger van de Ergast F1-API (geen sleutel nodig)
	property string apiBase: "https://api.jolpi.ca/ergast/f1"
	property string cachePath: "file:///mnt/data/tsc/pitwall_cache.json"
	property string settingsPath: "file:///mnt/data/tsc/pitwall_userSettings.json"
	property int refreshMinutes: 30

	// ---- Instellingen (worden bewaard) ----
	property bool dutchNames: true
	property bool alertRace: true
	property bool alertQuali: true
	property bool alertSprint: true
	property bool alertSound: true
	property int alertLead: 10                       // minuten vooraf
	property variant leadOptions: [5, 10, 15, 30, 60]
	property variant firedList: []

	// ---- Data ----
	property string season: ""
	property variant race: null          // {raw, round, circuit, locality, country, sessions:[{key,label,ts}]} of {none:true}
	property variant driverRows: []      // [{pos, name, family, sub, value, color}]
	property variant constructorRows: []
	property variant resultRows: []      // [{pos, name, sub, value, color, isStatus}]
	property string resultRaw: ""
	property variant calendar: []        // [{round, raw, locality, country, ts}]

	// ---- Status ----
	property string statusText: "Gegevens laden..."
	property double lastFetch: 0
	property bool fetching: false
	property int pending: 0
	property int okCount: 0

	// ---- Afgeleid (voor tile en scherm) ----
	property double nowTs: 0
	property double nextTs: 0
	property string countdownText: "--"
	property string sessionLabel: ""
	property string tileRace: "Pitwall"
	property string leaderText: ""

	// ---- Melding ----
	property bool alertOpen: false
	property string alertTitle: ""
	property string alertText: ""
	property variant audioObj: null
	property bool soundBroken: false

	// ---- Vertalingen ----
	property variant gpNl: ({
		"Australian Grand Prix": "GP van Australië",
		"Chinese Grand Prix": "GP van China",
		"Japanese Grand Prix": "GP van Japan",
		"Bahrain Grand Prix": "GP van Bahrein",
		"Saudi Arabian Grand Prix": "GP van Saoedi-Arabië",
		"Miami Grand Prix": "GP van Miami",
		"Emilia Romagna Grand Prix": "GP van Emilia-Romagna",
		"Monaco Grand Prix": "GP van Monaco",
		"Canadian Grand Prix": "GP van Canada",
		"Spanish Grand Prix": "GP van Spanje",
		"Barcelona Grand Prix": "GP van Barcelona",
		"Barcelona-Catalunya Grand Prix": "GP van Barcelona",
		"Madrid Grand Prix": "GP van Madrid",
		"Austrian Grand Prix": "GP van Oostenrijk",
		"British Grand Prix": "GP van Groot-Brittannië",
		"Belgian Grand Prix": "GP van België",
		"Hungarian Grand Prix": "GP van Hongarije",
		"Dutch Grand Prix": "GP van Nederland",
		"Italian Grand Prix": "GP van Italië",
		"Azerbaijan Grand Prix": "GP van Azerbeidzjan",
		"Singapore Grand Prix": "GP van Singapore",
		"United States Grand Prix": "GP van de Verenigde Staten",
		"Mexico City Grand Prix": "GP van Mexico-Stad",
		"Mexican Grand Prix": "GP van Mexico",
		"São Paulo Grand Prix": "GP van Brazilië",
		"Sao Paulo Grand Prix": "GP van Brazilië",
		"Brazilian Grand Prix": "GP van Brazilië",
		"Las Vegas Grand Prix": "GP van Las Vegas",
		"Qatar Grand Prix": "GP van Qatar",
		"Abu Dhabi Grand Prix": "GP van Abu Dhabi"
	})

	property variant countryNl: ({
		"Australia": "Australië",
		"Bahrain": "Bahrein",
		"Saudi Arabia": "Saoedi-Arabië",
		"USA": "Verenigde Staten",
		"United States": "Verenigde Staten",
		"Spain": "Spanje",
		"Austria": "Oostenrijk",
		"UK": "Verenigd Koninkrijk",
		"United Kingdom": "Verenigd Koninkrijk",
		"Belgium": "België",
		"Hungary": "Hongarije",
		"Netherlands": "Nederland",
		"Italy": "Italië",
		"Azerbaijan": "Azerbeidzjan",
		"Brazil": "Brazilië",
		"UAE": "Verenigde Arabische Emiraten",
		"Canada": "Canada",
		"Japan": "Japan",
		"China": "China",
		"Monaco": "Monaco",
		"Singapore": "Singapore",
		"Mexico": "Mexico",
		"Qatar": "Qatar"
	})

	property variant statusNlMap: ({
		"Finished": "Gefinisht",
		"Retired": "Uitgevallen",
		"Accident": "Ongeluk",
		"Collision": "Aanrijding",
		"Collision damage": "Schade na aanrijding",
		"Spun off": "Uitgespind",
		"Disqualified": "Gediskwalificeerd",
		"Did not start": "Niet gestart",
		"Withdrew": "Teruggetrokken",
		"Engine": "Motor",
		"Gearbox": "Versnellingsbak",
		"Transmission": "Transmissie",
		"Brakes": "Remmen",
		"Hydraulics": "Hydrauliek",
		"Suspension": "Ophanging",
		"Puncture": "Lekke band",
		"Tyre": "Band",
		"Overheating": "Oververhitting",
		"Electrical": "Elektrisch",
		"Power Unit": "Motorunit",
		"Power loss": "Vermogensverlies",
		"Water leak": "Waterlek",
		"Oil leak": "Olielek",
		"Fuel system": "Brandstofsysteem",
		"Clutch": "Koppeling",
		"Mechanical": "Mechanisch",
		"Damage": "Schade",
		"Wheel": "Wiel",
		"Vibrations": "Trillingen",
		"Driveshaft": "Aandrijfas",
		"Radiator": "Radiateur",
		"Out of fuel": "Zonder brandstof"
	})

	FileIO {
		id: cacheFile
		source: cachePath
	}

	FileIO {
		id: settingsFile
		source: settingsPath
	}

	Timer {
		id: tickTimer
		interval: 30000
		repeat: true
		running: true
		onTriggered: pitwallApp.updateCountdown()
	}

	Timer {
		id: refreshTimer
		interval: refreshMinutes * 60000
		repeat: true
		running: true
		onTriggered: pitwallApp.refresh()
	}

	onDutchNamesChanged: updateCountdown()

	function init() {
		registry.registerWidget("tile", tileUrl, this, "pitwallTile", {
			thumbLabel: "Pitwall F1",
			thumbIcon: thumbnailIcon,
			thumbCategory: "general",
			thumbWeight: 30,
			baseTileWeight: 10,
			baseTileSolarWeight: 10,
			thumbIconVAlignment: "center"
		});
		registry.registerWidget("screen", screenUrl, this, "pitwallScreen");
		registry.registerWidget("screen", settingsScreenUrl, this, "pitwallSettingsScreen");
		registry.registerWidget("screen", alertScreenUrl, this, "pitwallAlertScreen");
		loadSettings();
		loadCache();
		updateCountdown();
		refresh();
	}

	// ---------- Hulpfuncties ----------
	function nowMs() {
		return new Date().getTime();
	}

	function pad(n) {
		return (n < 10 ? "0" : "") + n;
	}

	function parseUtc(dateStr, timeStr) {
		var d = dateStr.split("-");
		var t = (timeStr ? timeStr : "12:00:00Z").replace("Z", "").split(":");
		return Date.UTC(parseInt(d[0], 10), parseInt(d[1], 10) - 1, parseInt(d[2], 10),
				parseInt(t[0], 10), parseInt(t[1], 10), t.length > 2 ? parseInt(t[2], 10) : 0);
	}

	function fmtWhen(ts) {
		var days = ["zo", "ma", "di", "wo", "do", "vr", "za"];
		var months = ["jan", "feb", "mrt", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec"];
		var d = new Date(ts);
		return days[d.getDay()] + " " + d.getDate() + " " + months[d.getMonth()] + "  " + pad(d.getHours()) + ":" + pad(d.getMinutes());
	}

	function fmtDate(ts) {
		var months = ["jan", "feb", "mrt", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec"];
		var d = new Date(ts);
		return d.getDate() + " " + months[d.getMonth()];
	}

	function fmtDiff(ms) {
		var mins = Math.floor(ms / 60000);
		var d = Math.floor(mins / 1440);
		var h = Math.floor((mins % 1440) / 60);
		var m = mins % 60;
		if (d > 0)
			return d + " d " + h + " u";
		if (h > 0)
			return h + " u " + pad(m) + " m";
		if (m < 1)
			return "< 1 min";
		return m + " min";
	}

	function shortTeam(name) {
		return String(name).replace(" F1 Team", "").replace(" Racing", "");
	}

	function shortName(driver) {
		var g = driver.givenName ? driver.givenName.charAt(0) + ". " : "";
		return g + driver.familyName;
	}

	// ---------- Namen (Engels of Nederlands) ----------
	function gpName(raw) {
		raw = String(raw);
		if (dutchNames && gpNl[raw])
			return gpNl[raw];
		return raw.replace(" Grand Prix", " GP");
	}

	function countryName(raw) {
		raw = String(raw);
		if (dutchNames && countryNl[raw])
			return countryNl[raw];
		return raw;
	}

	function placeText(locality, country) {
		return locality + ", " + countryName(country);
	}

	function statusName(raw) {
		raw = String(raw);
		if (!dutchNames)
			return raw;
		if (statusNlMap[raw])
			return statusNlMap[raw];
		var m = /^\+(\d+) Laps?$/.exec(raw);
		if (m)
			return "+" + m[1] + (m[1] === "1" ? " ronde" : " ronden");
		return raw;
	}

	// ---------- Teamkleuren ----------
	function teamColor(name, id) {
		var s = (String(name) + " " + String(id)).toLowerCase();
		if (String(id) === "rb" || s.indexOf("racing bulls") >= 0 || s.indexOf("rb f1") >= 0)
			return "#6692FF";
		if (s.indexOf("red bull") >= 0 || s.indexOf("red_bull") >= 0)
			return "#3671C6";
		if (s.indexOf("mercedes") >= 0)
			return "#27F4D2";
		if (s.indexOf("ferrari") >= 0)
			return "#E8002D";
		if (s.indexOf("mclaren") >= 0)
			return "#FF8000";
		if (s.indexOf("aston") >= 0)
			return "#229971";
		if (s.indexOf("alpine") >= 0)
			return "#0093CC";
		if (s.indexOf("williams") >= 0)
			return "#64C4FF";
		if (s.indexOf("haas") >= 0)
			return "#B6BABD";
		if (s.indexOf("sauber") >= 0)
			return "#52E252";
		if (s.indexOf("audi") >= 0)
			return "#6E7377";
		if (s.indexOf("cadillac") >= 0)
			return "#444444";
		return "#999999";
	}

	// ---------- Ophalen ----------
	function fetchJson(path, ok, fail) {
		try {
			var http = new XMLHttpRequest();
			http.open("GET", apiBase + path, true);
			http.onreadystatechange = function() {
				if (http.readyState === XMLHttpRequest.DONE) {
					if (http.status === 200) {
						try {
							ok(JSON.parse(http.responseText));
						} catch (e) {
							fail("data");
						}
					} else {
						fail(http.status);
					}
				}
			};
			http.send();
		} catch (e) {
			fail("fout");
		}
	}

	function requestDone(success) {
		if (success)
			okCount++;
		pending--;
		if (pending <= 0) {
			fetching = false;
			if (okCount > 0) {
				lastFetch = nowMs();
				var d = new Date(lastFetch);
				statusText = (okCount < 5 ? "Deels bijgewerkt " : "Bijgewerkt ") + pad(d.getHours()) + ":" + pad(d.getMinutes());
				saveCache();
			} else {
				statusText = "Geen verbinding, oude gegevens";
			}
			updateCountdown();
		}
	}

	function refresh() {
		if (fetching && nowMs() - lastFetch < 60000)
			return;
		fetching = true;
		pending = 5;
		okCount = 0;
		statusText = "Bijwerken...";

		fetchJson("/current/next.json", function(j) {
			parseNext(j);
			requestDone(true);
		}, function(e) {
			requestDone(false);
		});
		fetchJson("/current/driverstandings.json", function(j) {
			parseDrivers(j);
			requestDone(true);
		}, function(e) {
			requestDone(false);
		});
		fetchJson("/current/constructorstandings.json", function(j) {
			parseConstructors(j);
			requestDone(true);
		}, function(e) {
			requestDone(false);
		});
		fetchJson("/current/last/results.json", function(j) {
			parseResults(j);
			requestDone(true);
		}, function(e) {
			requestDone(false);
		});
		fetchJson("/current.json", function(j) {
			parseCalendar(j);
			requestDone(true);
		}, function(e) {
			requestDone(false);
		});
	}

	function refreshIfStale() {
		if (nowMs() - lastFetch > 5 * 60000)
			refresh();
	}

	// ---------- Verwerken ----------
	function parseNext(json) {
		var races = json.MRData.RaceTable.Races;
		if (!races || races.length === 0) {
			race = {none: true};
			return;
		}
		var r = races[0];
		var map = [
			["FirstPractice", "fp1", "Vrije training 1"],
			["SecondPractice", "fp2", "Vrije training 2"],
			["ThirdPractice", "fp3", "Vrije training 3"],
			["SprintQualifying", "sq", "Sprintkwalificatie"],
			["SprintShootout", "sq", "Sprintkwalificatie"],
			["Sprint", "sprint", "Sprint"],
			["Qualifying", "quali", "Kwalificatie"]
		];
		var s = [];
		for (var i = 0; i < map.length; i++) {
			var item = r[map[i][0]];
			if (item && item.date)
				s.push({key: map[i][1], label: map[i][2], ts: parseUtc(item.date, item.time)});
		}
		s.push({key: "race", label: "Race", ts: parseUtc(r.date, r.time)});
		s.sort(function(a, b) { return a.ts - b.ts; });

		race = {
			raw: r.raceName,
			round: String(r.round),
			circuit: r.Circuit ? r.Circuit.circuitName : "",
			locality: (r.Circuit && r.Circuit.Location) ? r.Circuit.Location.locality : "",
			country: (r.Circuit && r.Circuit.Location) ? r.Circuit.Location.country : "",
			sessions: s
		};
		if (r.season)
			season = r.season;
	}

	function parseDrivers(json) {
		var lists = json.MRData.StandingsTable.StandingsLists;
		if (!lists || lists.length === 0)
			return;
		var ds = lists[0].DriverStandings;
		var rows = [];
		for (var i = 0; i < ds.length; i++) {
			var d = ds[i];
			var team = "";
			var color = "#999999";
			if (d.Constructors && d.Constructors.length > 0) {
				var c = d.Constructors[d.Constructors.length - 1];
				team = shortTeam(c.name);
				color = teamColor(c.name, c.constructorId);
			}
			rows.push({
				pos: String(d.position),
				name: shortName(d.Driver),
				family: d.Driver.familyName,
				sub: team,
				value: String(d.points),
				color: color
			});
		}
		driverRows = rows;
		if (lists[0].season)
			season = lists[0].season;
	}

	function parseConstructors(json) {
		var lists = json.MRData.StandingsTable.StandingsLists;
		if (!lists || lists.length === 0)
			return;
		var cs = lists[0].ConstructorStandings;
		var rows = [];
		for (var i = 0; i < cs.length; i++) {
			var c = cs[i];
			rows.push({
				pos: String(c.position),
				name: shortTeam(c.Constructor.name),
				sub: c.wins + (String(c.wins) === "1" ? " zege" : " zeges"),
				value: String(c.points),
				color: teamColor(c.Constructor.name, c.Constructor.constructorId)
			});
		}
		constructorRows = rows;
	}

	function parseResults(json) {
		var races = json.MRData.RaceTable.Races;
		if (!races || races.length === 0)
			return;
		var res = races[0].Results;
		var rows = [];
		for (var i = 0; i < res.length; i++) {
			var x = res[i];
			rows.push({
				pos: String(x.position),
				name: shortName(x.Driver),
				sub: shortTeam(x.Constructor.name),
				value: x.Time ? x.Time.time : String(x.status),
				isStatus: !x.Time,
				color: teamColor(x.Constructor.name, x.Constructor.constructorId)
			});
		}
		resultRows = rows;
		resultRaw = races[0].raceName;
	}

	function parseCalendar(json) {
		var races = json.MRData.RaceTable.Races;
		if (!races || races.length === 0)
			return;
		var rows = [];
		for (var i = 0; i < races.length; i++) {
			var r = races[i];
			rows.push({
				round: String(r.round),
				raw: r.raceName,
				locality: (r.Circuit && r.Circuit.Location) ? r.Circuit.Location.locality : "",
				country: (r.Circuit && r.Circuit.Location) ? r.Circuit.Location.country : "",
				ts: parseUtc(r.date, r.time)
			});
		}
		calendar = rows;
		if (json.MRData.RaceTable.season)
			season = json.MRData.RaceTable.season;
	}

	// ---------- Afteltijd ----------
	function updateCountdown() {
		var now = nowMs();
		nowTs = now;

		if (driverRows.length > 0)
			leaderText = driverRows[0].family + " " + driverRows[0].value + " pt";
		else
			leaderText = "";

		if (!race) {
			countdownText = "--";
			sessionLabel = "";
			tileRace = "Pitwall";
			nextTs = 0;
			return;
		}
		if (race.none) {
			countdownText = "Tot volgend jaar";
			sessionLabel = "Seizoen afgelopen";
			tileRace = "Pitwall";
			nextTs = 0;
			return;
		}

		tileRace = gpName(race.raw);
		var s = race.sessions;
		var idx = -1;
		for (var i = 0; i < s.length; i++) {
			if (s[i].ts > now) {
				idx = i;
				break;
			}
		}

		if (idx >= 0) {
			nextTs = s[idx].ts;
			sessionLabel = s[idx].label;
			countdownText = fmtDiff(s[idx].ts - now);
		} else {
			var last = s[s.length - 1].ts;
			nextTs = 0;
			if (now - last < 2 * 3600000) {
				countdownText = "Race bezig";
				sessionLabel = "Live bij de Grand Prix";
			} else {
				countdownText = "Uitslag volgt";
				sessionLabel = "Race afgelopen";
			}
			// Na de race snel opnieuw ophalen, zodat de volgende race verschijnt
			if (now - lastFetch > 10 * 60000)
				refresh();
		}
		checkAlerts(now);
	}

	// ---------- Meldingen ----------
	function alertEnabled(key) {
		if (key === "race")
			return alertRace;
		if (key === "quali")
			return alertQuali;
		if (key === "sprint" || key === "sq")
			return alertSprint;
		return false;
	}

	function checkAlerts(now) {
		if (!race || race.none || !race.sessions)
			return;
		for (var i = 0; i < race.sessions.length; i++) {
			var s = race.sessions[i];
			if (!s.key || !alertEnabled(s.key))
				continue;
			var diff = s.ts - now;
			if (diff <= 0 || diff > alertLead * 60000)
				continue;
			var id = race.round + "-" + s.key + "-" + season;
			if (isFired(id))
				continue;
			markFired(id);
			fireAlert(s.label, diff);
			return;
		}
	}

	function isFired(id) {
		for (var i = 0; i < firedList.length; i++) {
			if (firedList[i] === id)
				return true;
		}
		return false;
	}

	function markFired(id) {
		var arr = [];
		for (var i = 0; i < firedList.length; i++)
			arr.push(firedList[i]);
		arr.push(id);
		while (arr.length > 40)
			arr.shift();
		firedList = arr;
		saveSettings();
	}

	function fireAlert(label, diff) {
		if (alertOpen)
			return;
		alertTitle = label;
		var when = diff < 60000 ? "Start nu" : "Start over " + fmtDiff(diff);
		alertText = when + "\n" + (race && !race.none ? gpName(race.raw) : "Formule 1");
		alertOpen = true;
		try {
			if (typeof screenStateController !== "undefined")
				screenStateController.wakeup();
		} catch (e) {}
		stage.openFullscreen(alertScreenUrl);
	}

	function testAlert() {
		fireAlert("Test: Race", 10 * 60000);
	}

	// Wordt aangeroepen als het meldingsscherm sluit
	function alertClosed() {
		alertOpen = false;
		stopSound();
	}

	function startSound() {
		if (!alertSound || soundBroken)
			return;
		try {
			if (audioObj === null) {
				audioObj = Qt.createQmlObject(
					'import QtQuick 2.1\nimport QtMultimedia 5.0\nAudio { source: "' + Qt.resolvedUrl("sounds/alert.wav") + '" }',
					pitwallApp, "pitwallAudio");
			}
			audioObj.stop();
			audioObj.play();
		} catch (e) {
			// Geen audio-module beschikbaar: alleen visuele melding
			soundBroken = true;
		}
	}

	function stopSound() {
		try {
			if (audioObj !== null)
				audioObj.stop();
		} catch (e) {}
	}

	// ---------- Opslag ----------
	function saveSettings() {
		try {
			settingsFile.write(JSON.stringify({
				dutchNames: dutchNames,
				alertRace: alertRace,
				alertQuali: alertQuali,
				alertSprint: alertSprint,
				alertSound: alertSound,
				alertLead: alertLead,
				fired: firedList
			}));
		} catch (e) {}
	}

	function loadSettings() {
		try {
			var s = settingsFile.read();
			if (s && s.length > 2) {
				var d = JSON.parse(s);
				if (d.dutchNames !== undefined) dutchNames = d.dutchNames;
				if (d.alertRace !== undefined) alertRace = d.alertRace;
				if (d.alertQuali !== undefined) alertQuali = d.alertQuali;
				if (d.alertSprint !== undefined) alertSprint = d.alertSprint;
				if (d.alertSound !== undefined) alertSound = d.alertSound;
				if (d.alertLead !== undefined) alertLead = d.alertLead;
				if (d.fired) firedList = d.fired;
			}
		} catch (e) {}
	}

	function stepLead(dir) {
		var idx = 0;
		for (var i = 0; i < leadOptions.length; i++) {
			if (leadOptions[i] === alertLead)
				idx = i;
		}
		idx += dir;
		if (idx < 0)
			idx = 0;
		if (idx > leadOptions.length - 1)
			idx = leadOptions.length - 1;
		alertLead = leadOptions[idx];
		saveSettings();
	}

	function saveCache() {
		try {
			cacheFile.write(JSON.stringify({
				v: 2,
				season: season,
				race: race,
				driverRows: driverRows,
				constructorRows: constructorRows,
				resultRows: resultRows,
				resultRaw: resultRaw,
				calendar: calendar,
				lastFetch: lastFetch
			}));
		} catch (e) {}
	}

	function loadCache() {
		try {
			var s = cacheFile.read();
			if (s && s.length > 2) {
				var d = JSON.parse(s);
				if (d.v !== 2)
					return;
				if (d.season) season = d.season;
				if (d.race) race = d.race;
				if (d.driverRows) driverRows = d.driverRows;
				if (d.constructorRows) constructorRows = d.constructorRows;
				if (d.resultRows) resultRows = d.resultRows;
				if (d.resultRaw) resultRaw = d.resultRaw;
				if (d.calendar) calendar = d.calendar;
				if (d.lastFetch) {
					lastFetch = d.lastFetch;
					var t = new Date(lastFetch);
					statusText = "Opgeslagen van " + pad(t.getHours()) + ":" + pad(t.getMinutes());
				}
			}
		} catch (e) {}
	}
}
