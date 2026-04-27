#!/bin/bash

# Konfiguration
SRC="/volume1/data/DS918_1.hbk"
DST="/volumeUSB1/usbshare/"
SMTP="203.0.113.104"
MAIL_TO="hostmaster@example.com"
MAIL_FROM="nas@ds918.local"
HOSTNAME=$(hostname)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Prüfen ob Quelle existiert
if [ ! -e "$SRC" ]; then
    SUBJECT="[FEHLER] copy2usb - Quelle nicht gefunden"
    BODY="Zeitpunkt: $TIMESTAMP
Host:      $HOSTNAME

FEHLER: Quelldatei/-ordner nicht gefunden:
$SRC

Das Backup wurde NICHT durchgeführt."

    send_mail "$SUBJECT" "$BODY"
    exit 1
fi

# Prüfen ob USB-Share gemountet/erreichbar ist
if [ ! -d "$DST" ]; then
    SUBJECT="[FEHLER] copy2usb - USB-Ziel nicht erreichbar"
    BODY="Zeitpunkt: $TIMESTAMP
Host:      $HOSTNAME

FEHLER: USB-Ziel nicht verfügbar:
$DST

Bitte prüfen ob die externe Festplatte angeschlossen und gemountet ist."

    send_mail "$SUBJECT" "$BODY"
    exit 2
fi

# Hilfsfunktion: Mail senden via SMTP (sendmail-Syntax)
send_mail() {
    local subject="$1"
    local body="$2"
    {
        echo "From: $MAIL_FROM"
        echo "To: $MAIL_TO"
        echo "Subject: $subject"
        echo "Date: $(date -R)"
        echo ""
        echo "$body"
    } | /bin/ssmtp "$MAIL_TO"
}

# Kopiervorgang starten, Fehlerausgabe mitloggen
ERROR_LOG=$(cp -rf "$SRC" "$DST" 2>&1)
EXIT_CODE=$?

# Ergebnis auswerten
if [ $EXIT_CODE -eq 0 ]; then
    # Zusätzliche Prüfung: Zieldatei/-ordner vorhanden?
    DST_CHECK="$DST$(basename "$SRC")"
    if [ -e "$DST_CHECK" ]; then
        SUBJECT="[OK] copy2usb - Backup erfolgreich"
        BODY="Zeitpunkt: $TIMESTAMP
Host:      $HOSTNAME

Backup erfolgreich abgeschlossen.

Quelle:  $SRC
Ziel:    $DST"
    else
        SUBJECT="[WARNUNG] copy2usb - cp ok, Ziel aber nicht verifizierbar"
        BODY="Zeitpunkt: $TIMESTAMP
Host:      $HOSTNAME

cp meldete Erfolg (Exit 0), jedoch konnte das Ziel nicht verifiziert werden.

Quelle:  $SRC
Ziel:    $DST_CHECK"
    fi
else
    SUBJECT="[FEHLER] copy2usb - Backup fehlgeschlagen (Exit $EXIT_CODE)"
    BODY="Zeitpunkt: $TIMESTAMP
Host:      $HOSTNAME

FEHLER beim Kopieren (Exit-Code: $EXIT_CODE)

Quelle:  $SRC
Ziel:    $DST

Fehlermeldung:
$ERROR_LOG"
fi

send_mail "$SUBJECT" "$BODY"
exit $EXIT_CODE