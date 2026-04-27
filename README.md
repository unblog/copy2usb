# copy2usb.sh

A simple backup helper script for Synology NAS that copies a Hyper Backup file or folder from a fixed source path to an external USB-mounted destination, then sends an email notification about the result.

## What it does

- Verifies the source backup path exists before attempting to copy.
- Verifies the destination USB mount path exists and is reachable.
- Copies the source to the destination using `cp -rf`.
- Checks whether the destination copy exists after a successful `cp`.
- Sends an email notification for success, warning, or failure.

## Script functions

### `send_mail()`

This helper function builds a simple email message with headers and body text, then pipes it into `/bin/ssmtp`.

- `From`: configured by `MAIL_FROM`
- `To`: configured by `MAIL_TO`
- `Subject`: set according to success or failure state
- `Date`: uses the current date in RFC 2822 format

## Configuration

Edit the top of `copy2usb.sh` to match your environment:

- `SRC` - source file or directory to copy
- `DST` - destination directory mounted from the USB drive
- `SMTP` - SMTP server address used by `ssmtp` (in this script the variable is defined but not directly used by `send_mail`)
- `MAIL_TO` - destination email address for notifications
- `MAIL_FROM` - sender email address used in the notification header

Example:

```bash
SRC="/volume1/data/DS918_1.hbk"
DST="/volumeUSB1/usbshare/"
SMTP="203.0.113.104"
MAIL_TO="hostmaster@example.com"
MAIL_FROM="nas@ds918.local"
```

## Usage

1. Make sure the script is executable:

```bash
chmod +x copy2usb.sh
```

2. Run the script manually:

```bash
./copy2usb.sh
```

3. Optionally schedule it with `cron` or Synology Task Scheduler to run regularly.

## Expected behavior

- If the source path does not exist, the script exits with code `1` and sends a failure email.
- If the destination USB mount is not reachable, it exits with code `2` and sends a failure email.
- If the copy command returns success but the copied destination is not verifiable, it sends a warning email.
- If the copy succeeds and the destination file or folder exists, it sends a success email.

## Requirements

- `bash`
- `cp`
- `ssmtp` configured and available at `/bin/ssmtp`

## Notes

- The script currently uses `cp -rf`, which overwrites existing files and copies recursively.
- The `SMTP` variable is defined for configuration consistency, but `send_mail()` relies on the `/bin/ssmtp` command and does not directly use the variable in this version.
