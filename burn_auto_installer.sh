#!/bin/bash

# Color and icon definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
ICON_DISCORD="👻"
ICON_INSTALL="🛠️"
ICON_LOGS="📄"
ICON_RESTART="🔄"
ICON_STOP="⏹️"
ICON_START="▶️"
ICON_EXIT="❌"
ICON_UPDATE="⛽️"








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
    echo -e "                ${GREEN}Server preparation ${RESET}"
    echo -e "    ${YELLOW}Please choose an option:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL}  Prepare Server"
    echo -e "    ${CYAN}2.${RESET} ${ICON_UPDATE} Update Server"
    echo -e "    ${CYAN}3.${RESET} ${ICON_RESTART} Reboot Server"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Exit"
    draw_bottom_border
    echo -ne "${YELLOW}Enter a command number [0-3]:${RESET} "
    read choice
}



prepare_server() {
    

    echo
    echo -e "${GREEN}🛠️  Server preparation starting...${RESET}"
    sudo apt -q update
    cd $HOME

    install_dependencies
    install_nvm
    install_nodeJS
    install_docker
    install_docker_compose
    install_go
    install_python
    
    
    echo -e "${GREEN}✅ Server prepared successfully.${RESET}"
    read -p "Press Enter to return to the menu..."
}

install_dependencies() {
    echo
    echo -e "${YELLOW}\nInstalling system dependencies...${RESET}"
    sudo apt update -y >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1
    sudo apt-get install -y screen curl unzip htop tar wget aria2 clang pkg-config libssl-dev jq build-essential git make ncdu npm >/dev/null 2>&1
    echo -e "${GREEN}✅ System dependencies installed successfully.${RESET}"
}

install_nvm() {
    echo
    echo -e "${YELLOW}\nInstalling NVM (Node Version Manager)...${RESET}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    echo -e "${GREEN}✅ NVM installed successfully.${RESET}"
}

install_nodeJS() {
    echo 
    echo -e "${YELLOW}\nInstalling Node.js using NVM...${RESET}"
    nvm install 20
    nvm use 20
    echo -e "${GREEN}✅ Node.js installed successfully.${RESET}"
}

install_go() {
  echo 
  echo -e "${YELLOW}\nInstalling Go...${RESET}"
  sudo rm -rf /usr/local/go
  curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
  echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
  source .bash_profile
  go version
  echo -e "${GREEN}✅ Go installed successfully.${RESET}"
}

install_python() {
  echo 
  echo -e "${YELLOW}\nInstalling Python...${RESET}"
  sudo apt install python3 -y
  python3 --version

  sudo apt install python3-pip -y
  pip3 --version
  echo -e "${GREEN}✅ Python installed successfully.${RESET}"

  echo 
  echo 
}

install_docker() {
    echo 
    echo -e "${YELLOW}\nChecking Docker installation...${RESET}"
    if ! command -v docker &> /dev/null; then
        echo -e "${COLOR_YELLOW}Docker not found. Installing Docker...${RESET}"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update >/dev/null 2>&1
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null 2>&1
        echo -e "${GREEN}Docker installed successfully.${RESET}"
        log_message "Docker installed."
        echo -e "${GREEN}✅ Docker installed successfully.${RESET}"
    else
        echo -e "${GREEN}✅ Docker is already installed.${RESET}"
    fi
    
}

install_docker_compose() {
    echo 
    echo -e "${YELLOW}\nChecking Docker Compose installation...${RESET}"
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${COLOR_YELLOW}Docker Compose not found. Installing Docker Compose...${RESET}"
        curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
         echo -e "${GREEN}✅ Docker Compose installed successfully.${RESET}"
    else
        echo -e "${GREEN}Docker Compose is already installed.${RESET}"
    fi
}

update_server() {
  echo 
  echo -e "${YELLOW}\nUpdating server...${RESET}"
  sudo apt update -y >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1
  echo -e "${GREEN}✅ Server updated successfully.${RESET}"
}

reboot_server() {
  echo 
  echo -e "${YELLOW}\nRebooting server...${RESET}"
  sudo reboot
  echo -e "${GREEN}✅ Server rebooted successfully.${RESET}"
}





# Main menu loop
while true; do
    show_menu
    case $choice in
        1)
            prepare_server
            ;;
        2)
            update_server
            ;;
        2)
            reboot_server
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
