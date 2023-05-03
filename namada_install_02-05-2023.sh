#function

center()
{ 
IFS=""
while read L
do
printf "%b\n" $(printf "%.$((($(tput cols)-${#L})/2))d" 0 | sed 's/0/ /g')$L
done
}

function colors {
  GREEN="\e[32m"
  NORM="\e[0m"
}

function logo {
bash <(curl -s https://raw.githubusercontent.com/Pandionidae/Additional_files/main/logo.sh)
}

function line {
  echo "--------------------------------------------------------------------------------"
}



function main_tools {
  sudo apt update
  sudo apt install mc wget curl git htop netcat net-tools unzip jq build-essential ncdu tmux make cmake clang pkg-config libssl-dev protobuf-compiler -y
  sudo apt install tar libclang-dev bsdmainutils gcc chrony liblz4-tool -y
  sudo apt install -y uidmap dbus-user-session
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
  source $HOME/.cargo/env
  sleep 3
  
  curl https://deb.nodesource.com/setup_16.x | sudo bash
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt install nodejs=16.* yarn  -y
  sleep 3
  

}

function go {
  bash <(curl -s https://raw.githubusercontent.com/Pandionidae/Additional_files/main/go.sh)
}

function vars {
  echo "export NAMADA_TAG=v0.15.1" >> ~/.bash_profile
  echo "export TM_HASH=v0.1.4-abciplus" >> ~/.bash_profile
  echo "export CHAIN_ID=public-testnet-7.0.3c5a38dc983" >> ~/.bash_profile
  echo "export VALIDATOR_ALIAS=$NAMADA_NAME" >> ~/.bash_profile
  echo "export WALLET=$NAMADA_NAME" >> ~/.bash_profile
  source ~/.bash_profile
}



function install_namada {
sudo wget -O $HOME/namada-v0.15.1-Linux-x86_64.tar.gz https://github.com/anoma/namada/releases/download/v0.15.1/namada-v0.15.1-Linux-x86_64.tar.gz
cd $HOME/
tar -xvf namada-v0.15.1-Linux-x86_64.tar.gz 


sudo mv $HOME/namada-v0.15.1-Linux-x86_64/namada /usr/local/bin/
sudo mv $HOME/namada-v0.15.1-Linux-x86_64/namada[c,n,w] /usr/local/bin/

sudo chmod +x /usr/local/bin/{tendermint,namada,namadac,namadan,namadaw}

rm -rf $HOME/namada-v0.15.1-Linux-x86_64
rm -rf $HOME/namada-v0.15.1-Linux-x86_64.tar.gz


cd $HOME && sudo rm -rf tendermint 
git clone https://github.com/heliaxdev/tendermint 
cd tendermint 
git checkout $TM_HASH
make build
sudo mv build/tendermint /usr/local/bin/
sudo chmod +x /usr/local/bin/{tendermint}
cd $HOME
namada client utils join-network --chain-id $CHAIN_ID
wget https://github.com/heliaxdev/anoma-network-config/releases/download/${CHAIN_ID}/${CHAIN_ID}.tar.gz
tar xvzf "$HOME/$CHAIN_ID.tar.gz"
mkdir -p $HOME/.namada/${CHAIN_ID}/tendermint/config/
wget -O $HOME/.namada/${CHAIN_ID}/tendermint/config/addrbook.json https://github.com/McDaan/general/raw/main/namada/addrbook.json
sudo sed -i 's/0\.0\.0\.0:26656/0\.0\.0\.0:51656/g; s/127\.0\.0\.1:26657/127\.0\.0\.1:51657/g' /root/.namada/public-testnet*/config.toml
}


function autoload_namada {
  sudo tee /etc/systemd/system/namada.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target

[Service]
User=root
WorkingDirectory=$HOME/.namada
Environment=NAMADA_LOG=debug
Environment=NAMADA_TM_STDOUT=true
ExecStart=/usr/local/bin/namada --base-dir=$HOME/.namada node ledger run
StandardOutput=syslog
StandardError=syslog
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable namada
  sudo systemctl restart namada
}




line | center
logo
line | center
if [ ! $NAMADA_NAME ]; then
	read -p "Введіть назву ноди: " NAMADA_NAME 
fi
sleep 1
line | center
echo "${GREEN}Встановлення додаткового хламу....${NORM}" | center
line | center
main_tools
go
line | center
echo "${GREEN}Встановлення і налаштування ноди namada${NORM}" | center
line | center
vars
install_namada
line | center


autoload_namada
line | center
echo "${GREEN}Ноду встановили і запустили, потрібно перевірити логи чи все добре працює! І виконати наступні кроки!${NORM}" | center
