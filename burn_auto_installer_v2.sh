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
PROJECT_NAME="t3rn"
VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep 'tag_name' | cut -d\" -f4 | grep -oP '(?<=v0\.)\d+')

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
    echo -e "          ${MAGENTA}${ICON_DISCORD} Join us on Discord!${RESET}"
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
    echo -e "    ${BLUE}Join us on Discord: ${YELLOW}https://discord.gg/uJEeSe9E${RESET}"
    draw_middle_border
    echo -e "                ${GREEN}Node Manager for ${PROJECT_NAME}${RESET}"
    echo -e "    ${YELLOW}Please choose an option:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL}  Install Node"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} View Logs"
    echo -e "    ${CYAN}3.${RESET} ${ICON_RESTART} Restart Node"
    echo -e "    ${CYAN}4.${RESET} ${ICON_STOP}  Stop Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_REMOVE}   Remove Node"
    echo -e "    ${CYAN}6.${RESET} ${ICON_START}  Start Node"
    echo -e "    ${CYAN}7.${RESET} ${ICON_DOLLAR} Check Wallet Balance"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Exit"
    draw_bottom_border
    echo -ne "${YELLOW}Enter a command number [0-7]:${RESET} "
    read choice
}

# Install node function with registration link and check
install_node() {
    echo 
    echo -e "${CYAN}To proceed, ensure you have at least ${RED}0.1 BRN ${CYAN}in your wallet.${RESET}"
    echo -e "${CYAN}Claim free BRN from the faucet here: https://faucet.brn.t3rn.io/${RESET}"
    
    echo 
    echo -ne "${YELLOW}Do you have sufficient BRN balance in your wallet? (y/n): ${RESET}"
    read registered

    if [[ "$registered" != "y" && "$registered" != "Y" ]]; then
        echo -e "${RED}You need at least 0.1 BRN to continue. Please claim some from the faucet.${RESET}"
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
        rm -fr $T3RN_DIR/executor
        rm -fr $T3RN_DIR/executor-linux-v0.$VERSION.0.tar.gz
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

    
    
    echo -e "${CYAN}⬇️   Downloading executor-linux-v0.$VERSION.0.tar.gz${RESET}"
    curl -L -O https://github.com/t3rn/executor-release/releases/download/v0.$VERSION.0/executor-linux-v0.$VERSION.0.tar.gz;
    echo

    echo -e "${YELLOW}🧰 Extracting the file...${RESET}";
    tar -xvzf executor-linux-v0.$VERSION.0.tar.gz;
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


    export NODE_ENV=testnet
    export LOG_LEVEL=debug
    export LOG_PRETTY=false
    
    export EXECUTOR_PROCESS_ORDERS=true
    export EXECUTOR_PROCESS_CLAIMS=true
    export EXECUTOR_PROCESS_BIDS_ENABLED=true
    export EXECUTOR_MAX_L3_GAS_PRICE=20000
    export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL
    export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'
   

    # Default RPC endpoints
    DEFAULT_RPC_ENDPOINTS_ARBT="https://arbitrum-sepolia-rpc.publicnode.com"
    DEFAULT_RPC_ENDPOINTS_BSSP="https://sepolia.base.org"
    DEFAULT_RPC_ENDPOINTS_BLSS="https://sepolia.blast.io"
    DEFAULT_RPC_ENDPOINTS_OPSP="https://sepolia.optimism.io"
    

    
     

    echo -ne "${RED}🔒  Enter your Alchemy API key:${RESET} "
    read   ALCHEMY_API_KEY
    echo -e "\n${GREEN}✅ Alchemy API key has been set.${RESET}"
    echo 
