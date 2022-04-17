# 1. windowToolboxMalwareRemoval
[![made-with-powershell](https://img.shields.io/badge/PowerShell-1f425f?logo=Powershell)](https://microsoft.com/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Repo:Size](https://img.shields.io/github/languages/code-size/pabumake/windowToolboxMalware-Removal)

wTM-Removal sucht nach der Schadsoftware "windowstoolbox" und entfernt diese von Ihrem Computer.

TLDR:
~~Bitte melden Sie dieses Repository: https://github.com/windowtoolbox/under_observation~~

Repo ist gelöscht. Danke für eure mithilfe 👍
## 1.1 Inhalt

- [1. windowToolboxMalwareRemoval](#1-windowtoolboxmalwareremoval)
  - [1.1 Inhalt](#11-inhalt)
- [2. Nutzung](#2-nutzung)
  - [2.1 Differentiation between OS Languages](#21-differentiation-between-os-languages)
- [3. Untersuchungsbericht der SemperVideo Discord Community](#3-untersuchungsbericht-der-sempervideo-discord-community)
  - [3.1 Deobfuscated](#31-deobfuscated)
  - [3.2 Sind Sie betroffen?](#32-sind-sie-betroffen)
  - [3.3 Warum sind nur "en-" Nutzer betroffen?](#33-warum-sind-nur-en--nutzer-betroffen)
- [4. Vielen Dank an](#4-vielen-dank-an)

# 2. Nutzung

1. Rechtsklick auf wTM-Removal.cmd <br> <img src="img/tutorial-1.png">
2. "Als Administrator ausführen"
3. Akzeptieren Sie das Popup der Benutzerkontensteuerung.<br><img src="img/tutorial-2.png">
4. Wenn Sie nach der Entfernung gefragt werden, antworten Sie mit Y/y und drücken Sie die Enter-Taste. <br><img src="img/tutorial-3.png"><br><img src="img/tutorial-4.png">
5. Starten Sie Ihr System neu und führen Sie das Script erneut aus.
6. Nach der dritten ausfführung sollten Sie die Meldung erhalten das nichts mehr gefunden wurde. 
7. Führen Sie die Windows Update Fehlersuche aus um den Vorgang abzuschließen.

Die Malware manipuliert in einzelnen Fällen den Windows Update Dienst. Dies soll verhindern das die Malware nach einem Update evtl. nicht mehr funktioniert.

## 2.1 Differentiation between OS Languages

Um die beschriebene Problematik in [Issue](https://github.com/pabumake/windowToolboxMalware-Removal/issues/8) wurde eine Farbliche abgrenzung eingefügt:
<img src="img/tutorial-5.png"><br>
<img src="img/tutorial-6.png>

Die Meldung wird nun in rot/grün unterschieden und für Farbblinde mit [ ! ] / [ - ].
Wir haben nun auch gelbe Schrift für kurze Erklärungen hinzugefügt. Für Farbblinde mit [ ? ] zu identifizieren.

# 3. Untersuchungsbericht der SemperVideo Discord Community

Die Schadsoftware um die es geht: https://github.com/windowtoolbox/powershell-windows-toolbox <br>
[Wayback Archive Link](https://web.archive.org/web/20220401004833/https://github.com/windowtoolbox/powershell-windows-toolbox) vor der Änderung des Repositories.

Zweiter Account: https://github.com/alexrybak0444 <br>
Hier könnte sich das originale Projekt befinden: https://github.com/WinTweakers/WindowsToolbox <br>

Gelöschter Issue in der Repository:<br>
[Wayback Archive Link](https://web.archive.org/web/20220409165432/https://github.com/windowtoolbox/powershell-windows-toolbox/issues/32) vor der Änderung des Repositories.

## 3.1 Deobfuscated
Vielen Dank an @ZerGo0 <br>
Stage 1: (@LinuxUserGD) <br>
https://gist.github.com/ZerGo0/aa0984800fd6da0a9d9e7842a0dc3645 <br>
[Erste Phase: Erklärt (Englisch)](https://gist.github.com/ZerGo0/aa0984800fd6da0a9d9e7842a0dc3645?permalink_comment_id=4127278#gistcomment-4127278)

Zweite Phase: <br>
https://gist.github.com/ZerGo0/690175a1163bd4747d825491810c6ebb <br>
[Zweite Phase: Erklärt (Englisch)](https://gist.github.com/ZerGo0/690175a1163bd4747d825491810c6ebb?permalink_comment_id=4127295#gistcomment-4127295)<br>

Dritte Phase:
https://gist.github.com/ZerGo0/ce1d2786cdb5ecca248f309a98b1d987 <br>
[Dritte Phase: Erklärt (Englisch)](https://gist.github.com/ZerGo0/ce1d2786cdb5ecca248f309a98b1d987?permalink_comment_id=4127311#gistcomment-4127311)

Showcase 1 (Hängt sich bei Curl auf) <br>
https://app.any.run/tasks/40c113ab-7908-4979-8810-8733fd67bf3a/

Showcase 2 / (Das Skript manuell weiterausführen) <br>
https://app.any.run/tasks/b6f0d354-bce5-401a-b422-08d262b2be82/

## 3.2 Sind Sie betroffen?
Um herauszufinden, ob Sie betroffen sind: <br>
Öffnen Sie PowerShell als Admin und führen Sie diesen Befehl aus:
```
Get-WinSystemLocale
```

Wenn der "Name" mit "en-" beginnt sind Sie nicht betroffen. <br>

Andernfalls, überprüfen Sie ob diese Verzeichnisse auf Ihrem System existieren:
```
C:\systemfile\
C:\Windows\security\pywinvera
C:\Windows\security\pywinveraa
```

Oder ob die folgenden Aufgaben in der Windows Aufgabenplanung existieren:
```
Microsoft\Windows\AppID\VerifiedCert
Microsoft\Windows\Application Experience\Maintenance
Microsoft\Windows\Services\CertPathCheck
Microsoft\Windows\Services\CertPathw
Microsoft\Windows\Servicing\ComponentCleanup
Microsoft\Windows\Servicing\ServiceCleanup
Microsoft\Windows\Shell\ObjectTask
Microsoft\Windows\Clip\ServiceCleanup
```

Wenn ja, sind Sie betroffen!

## 3.3 Warum sind nur "en-" Nutzer betroffen?
Die dritte Phase überprüft ob die Systemsprache mit "en-" beginnt. Falls nicht, wird der cmd.exe Prozess beendet und der Angriff beendet.<br>
Oben im ersten Showcase können Sie dieses Verhalten zurückverfolgen. Auf der rechten Seite in der Prozessliste führt 560 cmd.exe die PowerShell mit dieser Überprüfung aus.

![firefox_2022-04-10_17-37-14](https://user-images.githubusercontent.com/13680959/162627368-eede9728-ff01-4e39-9635-ab7276ff7438.png)

Für uns Deutsche zum Beispiel, schlägt diese Überprüfung fehl und der Prozess wird beendet.

# 4. Vielen Dank an
@BlockyTheDev <br>
blubbablasen <br>
Kay <br>
Limn0 <br>
@LinuxUserGD <br>
Mikasa <br>
@OptionalM <br>
Sonnenläufer <br>
@Zergo0 <br>
@Zuescho <br>
<b>für die Untersuchung</b><br>

Cirno <br>
Harromann <br>
Janmm14 <br>
@luzeadev  <br>
XplLiciT <br>
<b>für Bugfixes, Testing und QoS Verbesserungen</b><br>

@Zeryther<br>
<b>für die deutsche README Übersetzung</b>
