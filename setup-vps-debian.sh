#!/bin/bash

################
# Obtém e-mail #
################

# Função para validar email
validar_email() {
  local email="$1"
  if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0
  else
    return 1
  fi
}

# Passo 1: Solicitar o e-mail do usuário
echo -e "\n============================="
echo " Passo 1: Insira o seu e-mail"
echo "============================="

while true; do
  echo -e "\n📧 Por favor, insira seu e-mail:"
  read -p "> " EMAIL
  if validar_email "$EMAIL"; then
    echo -e "\n✅ Email válido: $EMAIL"
    echo "----------------"
    break
  else
    echo -e "❌ Email inválido. Tente novamente."
  fi
done


########################
# Baixar stack Traefik #
########################

# Passo 2: Baixar o arquivo stack-traefik-v2.yml e substituir o e-mail pelo informado
echo -e "\n================================"
echo " Passo 2: Baixando Stack Traefik"
echo "================================"
echo "🔄 Substituindo o e-mail no arquivo..."

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-traefik-v2.yml | sed "s/meuemail@email.com/${EMAIL}/g" > stack-traefik-v2.yml

if [[ -s stack-traefik-v2.yml ]]; then
  echo -e "✅ Stack Traefik baixada e e-mail substituído com sucesso."
else
  echo -e "❌ Erro: Arquivo final da Stack Traefik está vazio ou não foi gerado corretamente."
  exit 1
fi


#######################
# Update repositórios #
#######################

echo -e "\n=================================="
echo " Passo 3: Atualizando Repositórios"
echo "=================================="
apt-get update && apt install -y sudo gnupg2 wget ca-certificates apt-transport-https curl gnupg nano htop

if [ $? -eq 0 ]; then
    echo -e "✅ Repositórios atualizados com sucesso."
else
    echo -e "❌ Erro ao atualizar repositórios."
    exit 1
fi


##########
# Docker #
##########

echo -e "\n========================================="
echo " Passo 4: Verificando Chave GPG do Docker"
echo "========================================="
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
else
    echo "⚠️  Chave GPG do Docker já existe. Pulando."
fi

if [ $? -eq 0 ]; then
    echo -e "✅ Chave GPG adicionada com sucesso."
else
    echo -e "❌ Erro ao adicionar chave GPG."
    exit 1
fi


# Passo 5: Configurando Repositórios do Docker
echo -e "\n============================================="
echo " Passo 5: Configurando Repositórios do Docker"
echo "============================================="
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
else
    echo "⚠️  Repositórios do Docker já configurados. Pulando."
fi

if [ $? -eq 0 ]; then
    echo -e "✅ Repositórios do Docker configurados com sucesso."
else
    echo -e "❌ Erro ao configurar repositórios do Docker."
    exit 1
fi


# Passo 6: Instalar Docker
echo -e "\n==========================="
echo " Passo 6: Instalando Docker"
echo "==========================="
if ! command -v docker &> /dev/null; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    if [ $? -eq 0 ]; then
        echo -e "✅ Docker instalado com sucesso."
    else
        echo -e "❌ Erro ao instalar o Docker."
        exit 1
    fi
else
    echo "⚠️  Docker já instalado. Pulando."
fi


# Passo 7: Configurar Docker para iniciar automaticamente
echo -e "\n=========================================================="
echo " Passo 7: Configurando Docker para iniciar automaticamente"
echo "=========================================================="
if systemctl is-enabled docker.service | grep -q "enabled"; then
    echo "⚠️  Docker já configurado para iniciar automaticamente."
else
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    echo "✅ Serviço Docker configurado para iniciar automaticamente."
fi


##################
# Inicia o Swarm #
##################

# Passo 8: Obter o IP da máquina
echo -e "\n==============================="
echo " Passo 8: Obtendo IP da máquina"
echo "==============================="
IP_ADDR=$(hostname -I | awk '{print $1}')

if [ -z "$IP_ADDR" ]; then
    echo -e "❌ Erro ao obter IP da máquina."
    exit 1
else
    echo -e "✅ IP da máquina: $IP_ADDR"
fi


# Passo 9: Verificar se Docker Swarm já está inicializado
echo -e "\n=================================="
echo " Passo 9: Verificando Docker Swarm"
echo "=================================="
if docker info | grep -q "Swarm: active"; then
    echo "⚠️  Docker Swarm já inicializado. Pulando."
else
    docker swarm init --advertise-addr=$IP_ADDR
    if [ $? -eq 0 ]; then
        echo -e "✅ Docker Swarm inicializado com sucesso."
    else
        echo -e "❌ Erro ao inicializar Docker Swarm."
        exit 1
    fi
fi


#######################
# Verificar/criar rede#
#######################

# Passo 10: Verificar/criar a rede
echo -e "\n=================================================="
echo " Passo 10: Verificando Rede 'network_swarm_public'"
echo "=================================================="
if docker network ls | grep -q "network_swarm_public"; then
    echo "⚠️  Rede 'network_swarm_public' já existe. Pulando."
else
    docker network create --driver=overlay network_swarm_public
    if [ $? -eq 0 ]; then
        echo -e "✅ Rede 'network_swarm_public' criada com sucesso."
    else
        echo -e "❌ Erro ao criar a rede."
        exit 1
    fi
fi


#################
# Stack Traefik #
#################

# Passo 11: Subir stack do Traefik
echo -e "\n================================"
echo " Passo 11: Subindo Stack Traefik"
echo "================================"
docker stack deploy --prune --detach=false --resolve-image always -c stack-traefik-v2.yml traefik

if [ $? -eq 0 ]; then
    echo -e "✅ Stack Traefik implantada com sucesso!"
else
    echo -e "❌ Erro ao implantar Stack Traefik."
    exit 1
fi

echo -e "\n🚀 Script executado com sucesso!"
