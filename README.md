🚀 RocketBan

RocketBan is a modular, high-performance wrapper for Fail2Ban that enhances brute-force protection across Linux servers. It monitors authentication logs in real time, detects suspicious patterns using customizable regex rules, and dynamically applies IP bans via iptables or nftables. Whether you're running a personal VPS or managing enterprise infrastructure, RocketBan gives you fast, flexible, and reliable intrusion prevention—with just the right amount of attitude.
🔧 Features

    Real-Time Log Monitoring
    Continuously scans authentication logs for failed login attempts and other suspicious activity.

    Regex-Based Pattern Matching
    Define custom rules to match brute-force attempts across SSH, FTP, web apps, and more.

    Dynamic IP Banning
    Automatically applies firewall rules using iptables or nftables to block offending IPs.

    Timed Unban Logic
    Optionally unban IPs after a configurable timeout period.

    Multi-Service Support
    Monitor multiple log sources simultaneously with service-specific configurations.

    Threat Feed Integration (Optional)
    Pull known malicious IPs from external sources and preemptively block them.

    Verbose Logging & Audit Trail
    Track bans, unbans, and rule triggers with detailed logs for forensic analysis.

📜 License & Usage

RocketBan is released under the MIT License, a permissive open-source license that allows anyone to use, modify, distribute, and even incorporate the code into commercial projects—just keep the original license and attribution intact.

You are encouraged to:

✅ Use it in personal or business environments

✅ Fork it and build your own version

✅ Submit pull requests or improvements

✅ Share it with others who need better brute-force protection

This project is meant to be shared, remixed, and improved. Security should be collaborative—and a little fun.
📦 Installation

Clone the repository and make the script executable:

git clone https://github.com/yourusername/rocketban.git
cd rocketban
chmod +x rocketban.sh
