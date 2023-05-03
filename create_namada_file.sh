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
  source ~/.bash_profile
}



function install_namada {
cd $HOME && sudo rm -rf $HOME/namada 
git clone https://github.com/anoma/namada 
cd namada 
git checkout $NAMADA_TAG
make build-release
sudo mv target/release/namada /usr/local/bin/
sudo mv target/release/namada[c,n,w] /usr/local/bin/

cd $HOME && sudo rm -rf tendermint 
git clone https://github.com/heliaxdev/tendermint 
cd tendermint 
git checkout $TM_HASH
make build
sudo mv build/tendermint /usr/local/bin/
cd $HOME
namada client utils join-network --chain-id $CHAIN_ID
sleep 3

}





line | center
logo
sleep 1
line | center
echo "${GREEN}Встановлення додаткового хламу....${NORM}" | center
line | center
main_tools
line | center
go
line | center
echo "${GREEN}Створення файлів namada${NORM}" | center
line | center
vars
install_namada
line | center
echo "${GREEN}Створено 5 файлів${NORM}" | center
