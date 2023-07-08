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
sudo apt install mc wget curl git htop netcat net-tools unzip jq build-essential ncdu tmux make cmake clang pkg-config libssl-dev protobuf-compiler tar libclang-dev bsdmainutils gcc chrony liblz4-tool uidmap dbus-user-session -y
#rust
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
sleep 1
source $HOME/.profile
#nodejs
curl https://deb.nodesource.com/setup_16.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install nodejs=16.* yarn build-essential jq git -y
#go
sudo rm -rf /usr/local/go
curl https://dl.google.com/go/go1.20.3.linux-amd64.tar.gz | sudo tar -C /usr/local -zxvf -

cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

source $HOME/.profile
sleep 1
}

function delete_old_file {
  rm -rf $HOME/namada
  rm -rf $HOME/cometbft
  rm -rf $HOME/.masp-params
  rm -rf $HOME/.local/share/namada
}

function NAMADA_NAME {
  source $HOME/.bash_profile
  if [ ! $NAMADA_NAME ]; then
  echo "Назва ноди:"
  read NAMADA_NAME
  fi
}

function protoc {
  cd $HOME && rustup update
  curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v23.3/protoc-23.3-linux-x86_64.zip
  sudo unzip -o protoc-23.3-linux-x86_64.zip -d /usr/local bin/protoc
  sudo unzip -o protoc-23.3-linux-x86_64.zip -d /usr/local 'include/*'
  rm -f protoc-23.3-linux-x86_64.zip
}

function vars {
  sed -i '/public-testnet/d' "$HOME/.bash_profile"
  sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
  sed -i '/WALLET_ADDRESS/d' "$HOME/.bash_profile"
  sed -i '/CBFT/d' "$HOME/.bash_profile"
  echo "export NAMADA_TAG=v0.17.5" >> ~/.bash_profile
  echo "export CHAIN_ID=public-testnet-10.3718993c3648" >> ~/.bash_profile
  echo "export CBFT=v0.37.2" >> ~/.bash_profile
  echo "export VALIDATOR_ALIAS=$NAMADA_NAME" >> ~/.bash_profile
  echo "export WALLET=$NAMADA_NAME" >> ~/.bash_profile
  echo "export BASE_DIR=$HOME/.local/share/namada" >> ~/.bash_profile
  source ~/.bash_profile
}

function cometbft {
  source $HOME/.profile
  cd $HOME
  git clone https://github.com/cometbft/cometbft.git
  cd cometbft
  git checkout $CBFT
  make build
  cp $HOME/cometbft/build/cometbft /usr/local/bin/cometbft
}

function wget_bin {
  sudo wget -O /usr/local/bin/namada https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namada
  sudo wget -O /usr/local/bin/namadac https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadac
  sudo wget -O /usr/local/bin/namadan https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadan
  sudo wget -O /usr/local/bin/namadaw https://doubletop-bin.ams3.digitaloceanspaces.com/namada/$NAMADA_TAG/namadaw
  sudo wget -O /usr/local/bin/tendermint https://doubletop-bin.ams3.digitaloceanspaces.com/namada/tendermint
  sudo chmod +x /usr/local/bin/{tendermint,namada,namadac,namadan,namadaw}

}

function network {
  cd $HOME
  namada client utils join-network --chain-id $CHAIN_ID
  mkdir -p $HOME/.local/share/namada/${CHAIN_ID}/tendermint/config/
  wget -O $HOME/.local/share/namada/${CHAIN_ID}/cometbft/config/addrbook.json https://raw.githubusercontent.com/McDaan/general/main/namada/addrbook.json
  sudo sed -i 's/0\.0\.0\.0:26656/0\.0\.0\.0:51656/g; s/127\.0\.0\.1:26657/127\.0\.0\.1:51657/g; s/127\.0\.0\.1:26658/127\.0\.0\.1:51658/g' $HOME/.local/share/namada/public-testnet*/config.toml
}

function systemd_namada {
  sudo tee /etc/systemd/system/namada.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable namada
  sudo systemctl restart namada
}

colors
line | center
logo
line | center
NAMADA_NAME
line | center
echo "${GREEN}Встановлення додаткового хламу....${NORM}" | center
line | center
main_tools
protoc
delete_old_file
line | center
echo "${GREEN}Встановлення і налаштування ноди namada${NORM}" | center
vars
cometbft
wget_bin
line | center
network
systemd_namada
line | center
echo "${GREEN}Ноду встановили і запустили, потрібно перевірити логи чи все добре працює! І виконати наступні кроки!${NORM}" | center
line | center
