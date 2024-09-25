#!/bin/bash

################
# Obtem e-mail #
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

# Passo 1: Solicitar o email do usuário
echo ""
echo "Passo 1: Solicitar o email do usuário"
echo ""
while true; do
  read -p "Por favor, insira seu e-mail: " EMAIL
  if validar_email "$EMAIL"; then
    echo "Passo 1 concluído com sucesso. Email válido: $EMAIL"
    break
  else
    echo "Erro no Passo 1: Email inválido. Tente novamente."
  fi
done


########################
# Baixar stack traefik #
########################

# Passo 2: Baixar o arquivo stack-traefik-v2.yml e substituir o email pelo informado
echo "Passo 2: Baixando a stack Traefik e substituindo o e-mail..."
curl -s https://github.com/marioguima/email-marketing-lucrativo/raw/refs/heads/main/stack-traefik-v2.yml | sed "s/meuemail@email.com/$EMAIL/g" > stack-traefik-v2.yml

if [ $? -eq 0 ]; then
  echo "Passo 2 concluído. Stack Traefik baixada e e-mail substituído com sucesso."
else
  echo "Erro no Passo 2: Erro ao baixar ou modificar a stack Traefik."
  exit 1
fi
echo ""


#######################
# Update repositórios #
#######################

# Passo 3: Atualizr os repositórios e instalar as dependências necessárias
echo "Passo 3: Atualizando repositórios e instalando dependências necessárias..."
echo ""
apt-get update
apt install -y sudo gnupg2 wget ca-certificates apt-transport-https curl gnupg nano htop

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 3 concluído com sucesso."
else
    echo "Erro no Passo 3: Falha ao atualizar repositórios e instalar dependências."
    exit 1
fi
echo ""


##########
# Docker #
##########

# Passo 4: Adicionar a chave GPG do Docker
echo "Passo 4: Adicionando chave GPG do Docker..."
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
else
    echo "Aviso no Passo 4: Chave GPG do Docker já existe. Pulando este passo."
fi

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 4 concluído com sucesso."
else
    echo "Erro no Passo 4: Falha ao adicionar a chave GPG do Docker."
    exit 1
fi
echo ""

# Passo 5: Configurr os repositórios do Docker
echo "Passo 5: Configurando os repositórios do Docker..."
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
else
    echo "Aviso no Passo 5: Repositórios do Docker já configurados. Pulando este passo."
fi

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 5 concluído com sucesso."
else
    echo "Erro no Passo 5: Falha ao configurar os repositórios do Docker."
    exit 1
fi
echo ""

# Passo 6: Instalar o Docker
echo "Passo 6: Instalando o Docker..."
# Verifica se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Aviso do Passo6: Docker não está instalado. Instalando..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo ""
    if [ $? -eq 0 ]; then
        echo "Passo 6: Docker instalado com sucesso."
    else
        echo "Erro no Passo 6: Falha ao instalar o Docker."
        exit 1
    fi
else
    echo "Aviso no Passo 6: Docker já está instalado. Pulando a instalação."
fi
echo ""

# Passo 7: Configurar o docker para iniciar automaticamente
echo "Passo 7: Verificando se o Docker está configurado para iniciar automaticamente..."
if systemctl is-enabled docker.service | grep -q "enabled"; then
    echo "Aviso no Passo 7: Serviço Docker já está configurado para iniciar automaticamente."
else
    echo "Aviso do Passo 7: Habilitando o serviço Docker para iniciar automaticamente..."
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
fi

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 7 concluído com sucesso."
else
    echo "Erro no Passo 7: Falha ao configurar o Docker para iniciar automaticamente."
    exit 1
fi
echo ""


##################
# Inicia o Swarm #
##################

# Passo 8: Obtém o IP da máquina
echo "Passo 8: Obtendo o IP da máquina..."
IP_ADDR=$(hostname -I | awk '{print $1}')

echo ""
if [ -z "$IP_ADDR" ]; then
    echo "Erro no Passo 8: Não foi possível obter o IP da máquina."
    exit 1
else
    echo "Passo 8 concluído com sucesso. IP da máquina obtido: $IP_ADDR"
fi
echo ""

# Passo 9: Verifica se Swarm já está inicializado
if docker info | grep -q "Swarm: active"; then
    echo "Aviso do Passo 9: Docker Swarm já foi inicializado. Pulando esta etapa."
else
    echo "Aviso do Passo 9: Inicializando o Docker Swarm..."
    docker swarm init --advertise-addr=$IP_ADDR
    echo ""
    if [ $? -eq 0 ]; then
        echo "Passo 9: Docker Swarm inicializado com sucesso."
    else
        echo "Erro no Passo 9: Falha ao inicializar o Docker Swarm."
        exit 1
    fi
fi
echo ""


#################
# Stack Traefik #
#################

# Passo 10: Subir a stack do Traefik com o Docker Swarm
echo "Passo 10: Subindo a stack do Traefik com o Docker Swarm..."
docker stack deploy --prune --detach=false --resolve-image always -c stack-traefik-v2.yml traefik

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 10 executado com sucesso. Stack Traefik implantada com sucesso."
else
    echo "Erro no Passo 10: Falha ao implantar a stack Traefik."
    exit 1
fi

echo "Script executado com sucesso!"
