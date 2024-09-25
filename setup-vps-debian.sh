#!/bin/bash

##########
# Docker #
##########

echo "Passo 1: Atualizando repositórios e instalando dependências necessárias..."
echo ""
apt-get update
apt install -y sudo gnupg2 wget ca-certificates apt-transport-https curl gnupg nano htop

if [ $? -eq 0 ]; then
    echo "Passo 1 concluído com sucesso."
else
    echo "Erro no Passo 1: Falha ao atualizar repositórios e instalar dependências."
    exit 1
fi
echo ""

# Passo 2: Docker GPG key
echo "Passo 2: Adicionando chave GPG do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

if [ $? -eq 0 ]; then
    echo "Passo 2 concluído com sucesso."
else
    echo "Erro no Passo 2: Falha ao adicionar a chave GPG do Docker."
    exit 1
fi
echo ""

# Passo 3: Docker Apt sources
echo "Passo 3: Configurando os repositórios do Docker..."
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

if [ $? -eq 0 ]; then
    echo "Passo 3 concluído com sucesso."
else
    echo "Erro no Passo 3: Falha ao configurar os repositórios do Docker."
    exit 1
fi
echo ""

echo "Passo 4: Instalando o Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if [ $? -eq 0 ]; then
    echo "Passo 4 concluído com sucesso."
else
    echo "Erro no Passo 4: Falha ao instalar o Docker."
    exit 1
fi
echo ""

# Passo 5: Configurar o docker para iniciar automaticamente
echo "Passo 5: Configurando o Docker para iniciar automaticamente com o sistema..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

if [ $? -eq 0 ]; then
    echo "Passo 5 concluído com sucesso."
else
    echo "Erro no Passo 5: Falha ao configurar o Docker para iniciar automaticamente."
    exit 1
fi
echo ""

##################
# Inicia o Swarm #
##################

# Passo 6: Obtém o IP da máquina
echo "Passo 6: Obtendo o IP da máquina..."
IP_ADDR=$(hostname -I | awk '{print $1}')

if [ -z "$IP_ADDR" ]; then
    echo "Erro no Passo 6: Não foi possível obter o IP da máquina."
    exit 1
else
    echo "Passo 6 concluído com sucesso... IP da máquina obtido: $IP_ADDR"
fi
echo ""

# Passo 7: Inicializa o Docker Swarm com o IP obtido
echo "Passo 7: Inicializando o Docker Swarm..."
docker swarm init --advertise-addr=$IP_ADDR

if [ $? -eq 0 ]; then
    echo "Passo 7 concluído... Docker Swarm inicializado com sucesso."
else
    echo "Erro no Passo 7: Falha ao inicializar o Docker Swarm."
    exit 1
fi
echo ""

echo "Script executado com sucesso!"
