CosmosNodeUnjail is a script designed to manage and monitor Cosmos-based nodes. It checks if a node is jailed, verifies if the node is fully synchronized, and if so, unjails the node automatically. This tool is essential for maintaining the health and uptime of your Cosmos validators.

Features
•	Jail Status Check: Automatically checks if the node is currently jailed.
•	Synchronization Verification: Verifies if the node is fully synchronized with the blockchain.
•	Automatic Unjail: If the node is synchronized, the script will unjail it automatically.
•	Logging: Logs all activities and actions taken by the script.
•	Telegram Notifications: Sends notifications to a specified Telegram chat about the status and actions taken.

Installation
1.	Clone the Repository:
git clone https://github.com/your-username/CosmosNodeUnjail.git	
cd CosmosNodeUnjail
3.	Create Configuration File:
Create a file named config.sh and add your Telegram bot token and chat ID:
TELEGRAM_BOT_TOKEN="your-telegram-bot-token"
CHAT_ID="your-telegram-chat-id"
4.	Make the Script Executable:
chmod +x cosmos_node_guardian.sh

Configuration
•	config.sh: Store your confidential data such as Telegram bot token and chat ID.
TELEGRAM_BOT_TOKEN="your-telegram-bot-token"
CHAT_ID="your-telegram-chat-id"

Example Crontab Entry
To run the script periodically, you can add a cron job:
*/10 * * * * /path/to/cosmos_node_unjail.sh
This will run the script every 10 minutes.
