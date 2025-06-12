## Security Scan Findings (Bandit)

- [B201] Found `debug=True` in Flask — removed in favor of `debug=os.getenv("FLASK_DEBUG")`
- [B104] Found binding to all interfaces (`0.0.0.0`) — now controlled via `FLASK_HOST` env variable

These changes mitigate remote code execution and interface exposure risk in non-production environments.
