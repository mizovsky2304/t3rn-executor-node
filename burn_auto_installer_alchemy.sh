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




    #Alchemy API key for RPC node
    RPC_ENDPOINTS_ARBT="https://arb-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$DEFAULT_RPC_ENDPOINTS_ARBT"
    RPC_ENDPOINTS_BSSP="https://base-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$DEFAULT_RPC_ENDPOINTS_BSSP"
    RPC_ENDPOINTS_BLSS="https://blast-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$DEFAULT_RPC_ENDPOINTS_BLSS"
    RPC_ENDPOINTS_OPSP="https://opt-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY,$DEFAULT_RPC_ENDPOINTS_OPSP"
    RPC_ENDPOINTS_L1RN="https://brn.calderarpc.com/http,https://brn.rpc.caldera.xyz/"


    export RPC_ENDPOINTS_ARBT
    export RPC_ENDPOINTS_BSSP
    export RPC_ENDPOINTS_BLSS
    export RPC_ENDPOINTS_OPSP
    export RPC_ENDPOINTS_L1RN

    
    
   

    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
    export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false


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

# Check wallet balance function
check_wallet_balance() {
    echo -e "${BLUE}🔌  Checking js dependencies...${RESET}"
    echo

    # Install js 
    #npm init -y
    
    cd "$T3RN_DIR"  


    # Check & Install ethers
    if npm list ethers >/dev/null 2>&1; then
      echo -e "${GREEN}✅  ethers is already installed${RESET}"
    else
      echo -e "${RED}⚙️  ethers is not installed${RESET}"
        echo -e "${GREEN}🛠️  Installing ethers...${RESET}"
      npm install ethers
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ethers successfully installed${RESET}"
      else
        echo -e "${RED}❌ Failed to install ethers${RESET}"
        exit 1
      fi
    fi
    echo


    #Check & Install dotenv
    if npm list dotenv >/dev/null 2>&1; then
      echo -e "${GREEN}✅  dotenv is already installed${RESET}"
    else
      echo -e "${RED}⚙️  dotenv is not installed${RESET}"
        echo -e "${GREEN}🛠️  Installing dotenv...${RESET}"
      npm install dotenv
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ dotenv successfully installed${RESET}"
      else
        echo -e "${RED}❌ Failed to install dotenv${RESET}"
        exit 1
      fi
    fi
     echo
    
    

    # Load .env variable -> Private Key
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    else
        echo -e "${RED}⚠️  .env file not found!${RESET}"
        read -sp "Please enter your private key: " PRIVATE_KEY
        echo "PRIVATE_KEY_LOCAL=${PRIVATE_KEY_LOCAL}" >> .env
        echo
    fi


    # Verify if private key is set
    if [ -z "$PRIVATE_KEY_LOCAL" ]; then
        echo -e "${RED}❌ Private key is not provided. Exiting...${RESET}"
        exit 1
    else
        
        generate_getBalance_js_file
        echo

        echo -e "${BLUE}＄ Checking wallet balance...${RESET}"
        echo
        
        #BRN
        echo -e "${BLUE}⏱️  Checking BRN network...${RESET}"
        network="brn"
        node getBalance.js $network
        echo


        #Sepolia
        echo -e "${BLUE}⏱️  Checking Sepolia network...${RESET}"
        network="sepolia"
        node getBalance.js $network
        echo


        #Base
        echo -e "${BLUE}⏱️  Checking Base network...${RESET}"
        network="base_sepolia"
        node getBalance.js $network
        echo


        #Optimism
        echo -e "${BLUE}⏱️  Checking Optimism network...${RESET}"
        network="op_sepolia"
        node getBalance.js $network
        echo


        #Arbitrum
        echo -e "${BLUE}⏱️  Checking Arbitrum network...${RESET}"
        network="arbitrum_sepolia"
        node getBalance.js $network
        echo


        #Blast
        echo -e "${BLUE}⏱️  Checking Blast network...${RESET}"
        network="blast_sepolia"
        node getBalance.js $network
        echo
        
    fi


    


    read -p "Press Enter to return to the menu..."
}




generate_getBalance_js_file() {
    echo -e "${CYAN}📃 Generating getBalance.js file...${RESET}"
    echo

    cd "$T3RN_DIR"


    # Génération du fichier getBalance.js
    cat > getBalance.js << 'EOF'
const { ethers } = require("ethers");
require("dotenv").config();

const NETWORKS = {
  sepolia: "https://ethereum-sepolia-rpc.publicnode.com", // Standard Sepolia
  base_sepolia: "https://sepolia.base.org", // Base Sepolia
  op_sepolia: "https://optimism-sepolia-rpc.publicnode.com", // Optimism Sepolia
  arbitrum_sepolia: "https://arbitrum-sepolia-rpc.publicnode.com", // Arbitrum Sepolia
  blast_sepolia: "https://sepolia.blast.io", // Blast Sepolia
  brn: "https://brn.rpc.caldera.xyz/http", // BRN network
};

// Colors for pretty console outputs
const COLORS = {
  RESET: "\x1b[0m",
  GREEN: "\x1b[32m",
  BLUE: "\x1b[34m",
  CYAN: "\x1b[36m",
  YELLOW: "\x1b[33m",
  MAGENTA: "\x1b[35m",
};

// Function to get the ETH balance for the given private key and network
async function getEthBalance(pk, network) {
  const rpcUrl = NETWORKS[network.toLowerCase()];
  if (!rpcUrl) {
    console.error(
      `Invalid network: ${network}. Supported networks: ${Object.keys(
        NETWORKS
      ).join(", ")}`
    );
    return;
  }

  try {
    // Validate the private key format
    if (!ethers.isHexString(pk) || pk.length !== 66) {
      console.error("Invalid private key format.");
      return;
    }

    // Create wallet from private key
    const wallet = new ethers.Wallet(pk);

    // Derive the public address from the wallet
    const address = wallet.address;

    // Create a provider for the specified network
    const provider = new ethers.JsonRpcProvider(rpcUrl);

    // Fetch the ETH balance
    const balance = await provider.getBalance(address);

    // Convert the balance from wei to ETH
    const balanceInEth = ethers.formatEther(balance);

    // Adjust token label for BRN network
    const token = network !== "brn" ? "ETH" : "BRN";

    // Log the balance in a formatted way
    console.log(
      `The balance of ${address} on ${COLORS.CYAN}${network.toUpperCase()}${COLORS.RESET} is: ${COLORS.GREEN}${parseFloat(balanceInEth).toFixed(4)}${COLORS.RESET} ${token}`
    );
  } catch (error) {
    console.error("Error fetching the balance:", error);
  }
}

// If the script is run directly
if (require.main === module) {
  const privateKey = process.env.PRIVATE_KEY_LOCAL; // Retrieve the private key from .env
  const net = process.argv[2] || "sepolia"; // Default to 'sepolia' if no network is provided

  if (!privateKey) {
    console.error("PRIVATE_KEY_LOCAL is not set in the .env file");
    process.exit(1);
  }

  getEthBalance(privateKey, net); // Call the function with the private key and network
}
EOF

    echo -e "${GREEN}✅ getBalance.js file has been generated successfully.${RESET}"
    echo 
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
        7)
            check_wallet_balance
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
