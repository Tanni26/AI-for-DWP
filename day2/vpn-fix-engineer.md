# VPN Fix — Engineer Internal Note

- **Root cause:** Win11 in-place upgrade removed the legacy VPN client. Intune did not trigger re-deployment of the replacement client because the detection rule still referenced the old client binary — gap meant the app was never flagged as absent post-upgrade.
- **Action taken:** Manually purged stale VPN registry entries under `HKLM\SOFTWARE\<vendor>`. Force-triggered Intune sync via Company Portal > Sync. New VPN client deployed automatically within ~5 min post-sync. Split-tunnel config applied via Intune profile (confirmed in client UI and routing table).
- **Verification:** Confirmed connectivity to all internal subnets; no data loss.
- **Preventive action required:** Update the Intune detection rule to target the new client executable/version string. Audit all other app detection rules referencing legacy binaries before the next Win11 upgrade wave to prevent recurrence.
