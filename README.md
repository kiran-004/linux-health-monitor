# Linux Server Health Monitor

A Bash-based monitoring system that checks CPU, memory, disk, and Apache health
every 5 minutes using Cron, logs results, auto-restarts Apache if it goes down,
and serves a live HTML dashboard.

## Tools Used
- Linux (Ubuntu 22.04), Bash scripting
- Apache HTTP Server (web server + dashboard host)
- Cron (task scheduling / process automation)
- Git / GitHub (version control)

## Project Structure
| File | Purpose |
|------|---------|
| `health_check.sh` | Main monitoring script — checks CPU/memory/disk/Apache |
| `generate_dashboard.sh` | Reads log and generates HTML dashboard |
| `health.log` | Log file (auto-generated, not committed) |

## How to Run
1. Clone the repo
2. Make scripts executable: `chmod +x *.sh`
3. Run manually: `sudo ./health_check.sh`
4. Add to cron: `*/5 * * * * /path/to/health_check.sh`
5. View dashboard at: `http://localhost/dashboard.html`

## Key Concepts Demonstrated
- Linux system commands (top, free, df, systemctl)
- Bash scripting and conditional logic
- Process automation with Cron
- Incident management (auto-restart on failure)
- Log management
