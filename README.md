# Linux Admin Automation (Debian)

A mini project for freshers to demonstrate Linux system administration skills:

- Bulk user creation from CSV
- Secure random passwords (forced change on first login)
- Group management
- Process monitoring via cron (every 5 mins)
- Logging and log rotation

## Why this project?
Shows real admin tasks: user management, scripting, cron, logs, documentation, Git.

## Project Structure
/opt/linux-admin-automation
├── data/
│ └── users.csv
├── logs/
├── output/
├── scripts/
│ ├── user_bulk_create.sh
│ ├── user_delete.sh
│ ├── user_reset_password.sh
│ └── process_monitor.sh
└── README.md

## Quick Start
```bash
# Run bulk user creation
sudo bash scripts/user_bulk_create.sh

# Run monitoring once
bash scripts/process_monitor.sh

# Schedule monitor every 5 mins with cron
( crontab -l 2>/dev/null; echo "*/5 * * * * bash /opt/linux-admin-automation/scripts/process_monitor.sh" ) | crontab -

## CSV Format (users.csv)
username,full_name,groups,shell
alice,Alice Johnson,developers,sudo,/bin/bash
bob,Bob Kumar,developers,/bin/zsh
carol,Carol Singh,,/bin/bash

## Outputs
- Credentials: `output/credentials_YYYYmmdd.csv`
- Logs:
  - `logs/user_mgmt.log`
  - `logs/process_monitor.log`

## Troubleshooting
- Error: "This script must run as root" → Run with `sudo`
- Error: "CSV not found" → Make sure `data/users.csv` exists
- Error: "Invalid username" → Must match `[a-z_][a-z0-9._-]*`

## Future Enhancements
- Add systemd timer instead of cron
- Add backup script for `/home` directories
- Add unit tests with `bats`
- Dockerize the project

## License
This project is licensed under the [License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
