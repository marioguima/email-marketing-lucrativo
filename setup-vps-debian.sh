#!/bin/bash

echo ""
echo "Passo 1: Atualizando repositórios e instalando dependências necessárias..."
echo ""
apt-get update
apt install -y sudo gnupg2 wget ca-certificates apt-transport-https curl gnupg nano htop

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 1 concluído com sucesso."
else
    echo "Erro no Passo 1: Falha ao atualizar repositórios e instalar dependências."
    exit 1
fi
echo ""

# Passo 2: Docker GPG key
echo "Passo 2: Adicionando chave GPG do Docker..."
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
else
    echo "Chave GPG do Docker já existe. Pulando este passo."
fi

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 2 concluído com sucesso."
else
    echo "Erro no Passo 2: Falha ao adicionar a chave GPG do Docker."
    exit 1
fi
echo ""

# Passo 3: Docker Apt sources
echo "Passo 3: Configurando os repositórios do Docker..."
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
else
    echo "Repositórios do Docker já configurados. Pulando este passo."
fi

echo ""
if [ $? -eq 0 ]; then
    echo "Passo 3 concluído com sucesso."
else
    echo "Erro no Passo 3: Falha ao configurar os repositórios do Docker."
    exit 1
fi
echo ""

# Verifica se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker não está instalado. Instalando..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo ""
    if [ $? -eq 0 ]; then
        echo "Passo 4: Docker instalado com sucesso."
    else
        echo "Erro no Passo 4: Falha ao instalar o Docker."
        exit 1
    fi
else
    echo "Docker já está instalado. Pulando a instalação."
fi
echo ""

# Passo 5: Configurar o docker para iniciar automaticamente
echo "Passo 5: Verificando se o Docker está configurado para iniciar automaticamente..."
if systemctl is-enabled docker.service | grep -q "enabled"; then
    echo "Serviço Docker já está configurado para iniciar automaticamente."
else
    echo "Habilitando o serviço Docker para iniciar automaticamente..."
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
fi

echo ""
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

echo ""
if [ -z "$IP_ADDR" ]; then
    echo "Erro no Passo 6: Não foi possível obter o IP da máquina."
    exit 1
else
    echo "Passo 6 concluído com sucesso... IP da máquina obtido: $IP_ADDR"
fi
echo ""

# Verifica se Swarm já está inicializado
if docker info | grep -q "Swarm: active"; then
    echo "Docker Swarm já foi inicializado. Pulando esta etapa."
else
    echo "Inicializando o Docker Swarm..."
    docker swarm init --advertise-addr=$IP_ADDR
    echo ""
    if [ $? -eq 0 ]; then
        echo "Passo 7: Docker Swarm inicializado com sucesso."
    else
        echo "Erro no Passo 7: Falha ao inicializar o Docker Swarm."
        exit 1
    fi
fi
echo ""

echo "Script executado com sucesso!"
