#!/bin/bash

clear

#############################
# Função para exibir o menu #
#############################
menu_idioma() {
  echo ""
  echo "Escolha seu idioma / Choose your language / Elija su idioma / Choisissez votre langue / Scegli la tua lingua"
  echo "1) Português"
  echo "2) English"
  echo "3) Español"
  echo "4) Français"
  echo "5) Italiano"
  echo -e "Digite o número / Enter the number / Escriba el número / Entrez le numéro / Inserisci il numero"
  read -p "> " idioma
}

############################
# Definir mensagens no idioma escolhido
############################
definir_mensagens() {
  case $idioma in
    1)
      # Português
      msg_passo1="Passo 1: Insira o seu e-mail para configurar o Let's Encrypt (certificado SSL) no Traefik:"
      msg_solicita_email="📧 Por favor, insira seu e-mail:"
      msg_email_valido="✅ Email válido: "
      msg_email_invalido="❌ Email inválido. Tente novamente."
      
      msg_passo2="Passo 2: Baixando Stack Traefik:"
      msg_baixando_stack="🔄 Substituindo o e-mail no arquivo..."
      msg_stack_ok="✅ Stack Traefik baixada e e-mail substituído com sucesso."
      msg_stack_erro="❌ Erro: Arquivo final da Stack Traefik está vazio ou não foi gerado corretamente."
      msg_repo_ok="✅ Repositórios atualizados com sucesso."
      msg_repo_erro="❌ Erro ao atualizar repositórios."
      msg_docker_ok="✅ Docker instalado com sucesso."
      msg_docker_erro="❌ Erro ao instalar o Docker."
      msg_docker_chave="✅ Chave GPG adicionada com sucesso."
      msg_chave_erro="❌ Erro ao adicionar chave GPG."
      msg_swarm_ok="✅ Docker Swarm inicializado com sucesso."
      msg_swarm_erro="❌ Erro ao inicializar Docker Swarm."
      ;;
    2)
      # English
      msg_passo1="Step 1: Enter your email to configure Let's Encrypt (SSL certificate) in Traefik:"
      msg_solicita_email="📧 Please enter your email:"
      msg_email_valido="✅ Valid email: "
      msg_email_invalido="❌ Invalid email. Please try again."
      
      msg_passo2="Step 2: Downloading Traefik Stack:"
      msg_baixando_stack="🔄 Replacing the email in the file..."
      msg_stack_ok="✅ Traefik stack downloaded and email replaced successfully."
      msg_stack_erro="❌ Error: Final Traefik stack file is empty or not generated correctly."
      msg_repo_ok="✅ Repositories updated successfully."
      msg_repo_erro="❌ Error updating repositories."
      msg_docker_ok="✅ Docker installed successfully."
      msg_docker_erro="❌ Error installing Docker."
      msg_docker_chave="✅ GPG key added successfully."
      msg_chave_erro="❌ Error adding GPG key."
      msg_swarm_ok="✅ Docker Swarm initialized successfully."
      msg_swarm_erro="❌ Error initializing Docker Swarm."
      ;;
    3)
      # Español
      msg_passo1="Paso 1: Ingrese su correo electrónico para configurar Let's Encrypt (certificado SSL) en Traefik:"
      msg_solicita_email="📧 Por favor ingrese su correo electrónico:"
      msg_email_valido="✅ Correo válido: "
      msg_email_invalido="❌ Correo inválido. Inténtalo de nuevo."
      
      msg_passo2="Paso 2: Descargando Stack Traefik:"
      msg_baixando_stack="🔄 Reemplazando el correo en el archivo..."
      msg_stack_ok="✅ Traefik descargado y correo reemplazado correctamente."
      msg_stack_erro="❌ Error: Archivo final de la Stack Traefik está vacío o no se generó correctamente."
      msg_repo_ok="✅ Repositorios actualizados correctamente."
      msg_repo_erro="❌ Error al actualizar repositorios."
      msg_docker_ok="✅ Docker instalado correctamente."
      msg_docker_erro="❌ Error al instalar Docker."
      msg_docker_chave="✅ Clave GPG añadida correctamente."
      msg_chave_erro="❌ Error al añadir clave GPG."
      msg_swarm_ok="✅ Docker Swarm iniciado correctamente."
      msg_swarm_erro="❌ Error al iniciar Docker Swarm."
      ;;
    4)
      # Français
      msg_passo1="Étape 1 : Entrez votre e-mail pour configurer Let's Encrypt (certificat SSL) dans Traefik :"
      msg_solicita_email="📧 Veuillez entrer votre e-mail :"
      msg_email_valido="✅ E-mail valide: "
      msg_email_invalido="❌ E-mail invalide. Veuillez réessayer."
      
      msg_passo2="Étape 2 : Téléchargement de la Stack Traefik :"
      msg_baixando_stack="🔄 Remplacement de l'e-mail dans le fichier..."
      msg_stack_ok="✅ Stack Traefik téléchargée et e-mail remplacé avec succès."
      msg_stack_erro="❌ Erreur : Le fichier final du Stack Traefik est vide ou n'a pas été généré correctement."
      msg_repo_ok="✅ Dépôts mis à jour avec succès."
      msg_repo_erro="❌ Erreur lors de la mise à jour des dépôts."
      msg_docker_ok="✅ Docker installé avec succès."
      msg_docker_erro="❌ Erreur lors de l'installation de Docker."
      msg_docker_chave="✅ Clé GPG ajoutée avec succès."
      msg_chave_erro="❌ Erreur lors de l'ajout de la clé GPG."
      msg_swarm_ok="✅ Docker Swarm initialisé avec succès."
      msg_swarm_erro="❌ Erreur lors de l'initialisation de Docker Swarm."
      ;;
    5)
      # Italiano
      msg_passo1="Passo 1: Inserisci la tua e-mail per configurare Let's Encrypt (certificato SSL) in Traefik:"
      msg_solicita_email="📧 Inserisci la tua e-mail:"
      msg_email_valido="✅ E-mail valido: "
      msg_email_invalido="❌ E-mail non valido. Riprova."
      
      msg_passo2="Passo 2: Scaricando Stack Traefik:"
      msg_baixando_stack="🔄 Sostituendo l'e-mail nel file..."
      msg_stack_ok="✅ Stack Traefik scaricato e e-mail sostituita con successo."
      msg_stack_erro="❌ Errore: Il file finale dello Stack Traefik è vuoto o non è stato generato correttamente."
      msg_repo_ok="✅ Repository aggiornati con successo."
      msg_repo_erro="❌ Errore durante l'aggiornamento dei repository."
      msg_docker_ok="✅ Docker installato con successo."
      msg_docker_erro="❌ Errore durante l'installazione di Docker."
      msg_docker_chave="✅ Chiave GPG aggiunta con successo."
      msg_chave_erro="❌ Errore durante l'aggiunta della chiave GPG."
      msg_swarm_ok="✅ Docker Swarm avviato con successo."
      msg_swarm_erro="❌ Errore durante l'avvio di Docker Swarm."
      ;;
    *)
      echo "Opção inválida. Tente novamente."
      return 1
      ;;
  esac
  return 0
}

##############################
# Loop para garantir escolha #
##############################
while true; do
  menu_idioma
  if definir_mensagens; then
    break
  fi
done

#############################################################
# Função para imprimir uma linha de caracteres com um texto #
#############################################################
print_with_line() {
    local texto="$1"        # O texto a ser exibido
    local tamanho=${#texto} # Conta o número de caracteres na string
    local caracter="="

    # Repete o caractere pelo tamanho da string
    local repeticao=$(printf "%${tamanho}s" | tr " " "$caracter")

    echo "$repeticao"  # Exibe a linha de caracteres superior
    echo "$texto"      # Exibe o texto
    echo "$repeticao"  # Exibe a linha de caracteres inferior
}

############################
# Função para validar email #
############################
validar_email() {
  local email="$1"
  if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0
  else
    return 1
  fi
}

############################
# Passo 1: Solicitar o e-mail do usuário
############################
print_with_line "$msg_passo1"

while true; do
  echo -e "\n$msg_solicita_email"
  read -p "> " EMAIL
  if validar_email "$EMAIL"; then
    echo -e "\n$msg_email_valido $EMAIL"
    echo "----------------"
    break
  else
    echo -e "$msg_email_invalido"
  fi
done

#################################
# Passo 2: Baixar stack Traefik #
#################################
print_with_line "$msg_passo2"
echo "$msg_baixando_stack"

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-traefik-v2.yml | sed "s/meuemail@email.com/${EMAIL}/g" > stack-traefik-v2.yml

if [[ -s stack-traefik-v2.yml ]]; then
  echo -e "$msg_stack_ok"
else
  echo -e "$msg_stack_erro"
  exit 1
fi


################################
# Passo 3: Update repositórios #
################################
echo -e "\n=================================="
echo " Passo 3: Atualizando Repositórios"
echo "=================================="
apt-get update && apt install -y sudo gnupg2 wget ca-certificates apt-transport-https curl gnupg nano htop

if [ $? -eq 0 ]; then
    echo -e "$msg_repo_ok"
else
    echo -e "$msg_repo_erro"
    exit 1
fi


#########################################
# Passo 4: Baixar e configurar o Docker #
#########################################
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
