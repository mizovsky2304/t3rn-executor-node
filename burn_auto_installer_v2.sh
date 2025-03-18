#!/bin/bash

# Color and icon definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_LOGS="📄"
ICON_RESTART="🔄"
ICON_STOP="⏹️"
ICON_START="▶️"
ICON_EXIT="❌"
ICON_REMOVE="🗑️"
ICON_VIEW="👀"
ICON_DOLLAR="💳"
ICON_UPDATE="⛽️"



# Global variables
PROJCET_NAME="t3rn"
#VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep 'tag_name' | cut -d\" -f4 | grep -oP '(?<=v0\.)\d+')

T3RN_DIR="$HOME/t3rn"
ENV_FILE="$T3RN_DIR/.env"
LOGFILE="$T3RN_DIR/executor.log"
NODE_PM2_NAME="executor"

# Draw menu borders and telegram icon
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${RESET}"
}
draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════╣${RESET}"
}
draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
}
print_telegram_icon() {
    echo -e "          ${MAGENTA}${ICON_DISCORD} Join us on Disord!${RESET}"
}
display_ascii() {
    echo -e "${RED}    ____                  _          ____      _            _  _         ${RESET}"    
    echo -e "${GREEN}   / ___|_ __ _   _ _ __ | |_ ___   | __ )  __| | __ _ _ __(_)(_) __ _   ${RESET}" 
    echo -e "${BLUE}  | |   | '__| | | | '_ \\| __/ _ \\  |  _ \\ / _\` |/ _\` | '__| || |/ _\` |  ${RESET}"
    echo -e "${YELLOW}  | |___| |  | |_| | |_) | || (_) | | |_) | (_| | (_| | |  | || | (_| |  ${RESET}"
    echo -e "${MAGENTA}   \\____|_|   \\__, | .__/ \\__\\___/  |____/ \\__,_|\\__,_|_|  |_|/ |\\__,_|  ${RESET}"
    echo -e "${RED}              |___/|_|                                      |__/        ${RESET}"       
}





# Display main menu
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Join us on Disord: ${YELLOW}https://discord.gg/uJEeSe9E${RESET}"
    draw_middle_border
    echo -e "                ${GREEN}Node Manager for ${PROJCET_NAME}${RESET}"
    echo -e "    ${YELLOW}Please choose an option:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL}  Install Node"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} View Logs"
    echo -e "    ${CYAN}3.${RESET} ${ICON_RESTART} Restart Node"
    echo -e "    ${CYAN}4.${RESET} ${ICON_STOP}  Stop Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_REMOVE}   Remove Node"
    echo -e "    ${CYAN}6.${RESET} ${ICON_START}  Start Node"
       
    
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Exit"
    draw_bottom_border
    echo -ne "${YELLOW}Enter a command number [0-6]:${RESET} "
    read choice
}


# Install node function with registration link and check
install_node() {
    echo 
    echo -e "${CYAN}To proceed, ensure you have at least ${RED}0.1 B2N ${CYAN}in your wallet.${RESET}"
    echo -e "${CYAN}Claim free BRN from the faucet here: https://b2n.hub.caldera.xyz/${RESET}"
    
    echo 
    echo -ne "${YELLOW}Do you have sufficient BRN balance in your wallet? (y/n): ${RESET}"
    read registered

    if [[ "$registered" != "y" && "$registered" != "Y" ]]; then
        echo -e "${RED}You need at least 0.1 B2N to continue. Please claim some from the faucet.${RESET}"
        read -p "Press Enter to return to the menu..."
        return
    fi

    echo
    echo -e "${GREEN}🛠️  Installing node...${RESET}"
    sudo apt -q update
    cd $HOME
    

    echo
    # Create t3rn Folder
    if [ ! -d "$T3RN_DIR" ]; then
        mkdir -p "$T3RN_DIR"
        cd "$T3RN_DIR"
        echo -e "${CYAN}🗂️  Folder $T3RN_DIR created.${RESET}"
    else
        echo -e "${RED}🗂️  Folder $T3RN_DIR already exist.${RESET}"
        rm -fr $T3RN_DIR/*
        
    fi
    echo 

    cd "$T3RN_DIR"
      
    
    # Check & Install ethers
    echo
    if npm list ethers >/dev/null 2>&1; then
      echo -e "${GREEN}⚙️  ethers is already installed${RESET}"
    else
      echo -e "${RED}⚙️  ethers is not installed${RESET}"
        echo -e "${GREEN}🛠️  Installing ethers...${RESET}"
      npm install -g ethers
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ethers successfully installed${RESET}"
      else
        echo -e "${RED}❌ Failed to install ethers${RESET}"
        exit 1
      fi
    fi
    echo 


    #Check & Install dotenv
    echo
    if npm list dotenv >/dev/null 2>&1; then
      echo -e "${GREEN}⚙️  dotenv is already installed${RESET}"
    else
      echo -e "${RED}⚙️  dotenv is not installed${RESET}"
        echo -e "${GREEN}🛠️  Installing dotenv...${RESET}"
      npm  install -g dotenv
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ dotenv successfully installed${RESET}"
      else
        echo -e "${RED}❌ Failed to install dotenv${RESET}"
        exit 1
      fi
    fi
    echo


    # Check & Install pm2
    echo
    if ! command -v pm2 &> /dev/null; then
      echo -e "${RED}⚙️  pm2 is not installed. Processing installation${RESET}"
      npm install -g pm2
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ pm2 successfully installed${RESET}"
      else
        echo -e "${RED}❌ Failed to install pm2${RESET}"
        exit 1
      fi
    else
      echo -e "${GREEN}⚙️  pm2 already installed.${RESET}"
        # Check if the instance exists
        if pm2 list | grep -q "$NODE_PM2_NAME"; then
          echo
          echo -e "${YELLOW}⚙️  Stopping and deleting existing instance: $NODE_PM2_NAME${RESET}"
          pm2 stop $NODE_PM2_NAME >/dev/null 2>&1
          pm2 delete $NODE_PM2_NAME >/dev/null 2>&1
        fi
    fi
    echo

    
    
    echo -e "${CYAN}⬇️   Downloading executor archive file${RESET}"
    curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -Po '"tag_name": "\K.*?(?=")' | \
xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz
    echo

    echo -e "${YELLOW}🧰 Extracting the file...${RESET}";
    tar -xzf executor-linux-*.tar.gz
    echo

    # Check if extraction was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅  Extraction successful.${RESET}"
    else
        echo -e "${RED}❌  Extraction failed, please check the tar.gz file.${RESET}"
        exit 1
    fi
    echo


    # Check if the extracted files contain 'executor'
    echo -e "${BLUE}⁉️  Checking if the extracted files or directories contain 'executor'...${RESET}"
    if ls | grep -q 'executor'; then
        echo -e "${GREEN}✅  Check passed, found files or directories containing 'executor'.${RESET}"
    else
        echo -e "${RED}❌  No files or directories containing 'executor' were found, possibly incorrect file name.${RESET}"
        exit 1
    fi
    echo


    # Verify .env file + private key
    if [ -f "$ENV_FILE" ]; then
        echo
        echo -e "${GREEN}✅ $ENV_FILE  found.${RESET}"
        
        # load environement variables
        source "$ENV_FILE"
        
        if [ -n "$PRIVATE_KEY_LOCAL" ]; then
            echo
            echo -e "${GREEN}🔑 PRIVATE_KEY_LOCAL is already set in $ENV_FILE.${RESET}"
        else
            echo -e "${RED}❌ PRIVATE_KEY_LOCAL variable is not set !!!${RESET}"
            echo
        fi
    else
      echo -e "${RED}❌ $ENV_FILE not found !!!${RESET}"
      echo 
      echo 
      echo -ne "${RED}🔑  Enter your EVM private key  [Burner Wallet]:${RESET} "
      read -s  PRIVATE_KEY_LOCAL
      echo "PRIVATE_KEY_LOCAL=${PRIVATE_KEY_LOCAL}" > $ENV_FILE
      source "$ENV_FILE"
      echo -e "\n${GREEN}✅ Private key has been set.${RESET}"
      echo 
    fi
    echo


export ENVIRONMENT=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
export EXECUTOR_MAX_L3_GAS_PRICE=200
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false

export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,unichain-sepolia,blast-sepolia,l2rn'
   

        
export RPC_ENDPOINTS='{
    "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"],
    "blst": ["https://sepolia.blast.io", "https://endpoints.omniatech.io/v1/blast/sepolia/public"]
}'

    
     

    


    

    


    

    
    # Start the executor process with pm2
    pm2 start ./executor/executor/bin/executor --name $NODE_PM2_NAME --log "$LOGFILE" --env NODE_ENV=$NODE_ENV --env LOG_LEVEL=$LOG_LEVEL --env LOG_PRETTY=$LOG_PRETTY --env ENABLED_NETWORKS=$ENABLED_NETWORKS --env PRIVATE_KEY_LOCAL="$PRIVATE_KEY_LOCAL";

   

    
    echo -e "${GREEN}✅ Node installed successfully. Check the logs to confirm authentication.${RESET}"
    read -p "Press Enter to return to the menu..."
}


# View logs function
view_logs() {
    echo -e "${GREEN}📄 Viewing logs...${RESET}"
    #pm2 logs $NODE_PM2_NAME --lines 50 
    tail -n 50 $LOGFILE
    
    echo
    read -p "Press Enter to return to the menu..."
}

# Restart node function
restart_node() {
    echo -e "${GREEN}🔄 Restarting node...${RESET}"
    pm2 restart $NODE_PM2_NAME
    echo -e "${GREEN}✅ Node restarted.${RESET}"
    read -p "Press Enter to return to the menu..."
}

# Stop node function
stop_node() {
    echo 
    echo -e "${YELLOW}⏹️  Stopping node...${RESET}"
    echo 
    pm2 stop $NODE_PM2_NAME
    echo -e "${GREEN}✅ Node stopped.${RESET}"
    
    echo
    echo
    echo
    read -p "Press Enter to return to the menu..."
}

# Start node function
start_node() {
    echo -e "${GREEN}▶️ Starting node...${RESET}"
    pm2 start $NODE_PM2_NAME
    echo -e "${GREEN}✅ Node started.${RESET}"
    read -p "Press Enter to return to the menu..."
}

# Remove node function
remove_node() {
    echo 
    echo -e "${YELLOW}🗑️  Removing node...${RESET}"
    echo
    pm2 delete $NODE_PM2_NAME
    echo
    rm -fr "$T3RN_DIR/executor" "$T3RN_DIR/executor.log" "$T3RN_DIR/getBalance.js" "$T3RN_DIR/.env" $T3RN_DIR/*.tar.gz
    
    echo
    echo -e "${GREEN}✅ Node removed.${RESET}"
    
    
    
    echo
    echo
    echo
    read -p "Press Enter to return to the menu..."
}










# Main menu loop
while true; do
    show_menu
    case $choice in
        1)
            install_node
            ;;
        2)
            view_logs
            ;;
        3)
            restart_node
            ;;
        4)
            stop_node
            ;;
        5)
            remove_node
            ;;    
        6)
            start_node
            ;;
        0)
            echo -e "${GREEN}❌ Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid input. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
