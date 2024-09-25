#!/bin/bash

clear

#############################
# Função para exibir o menu #
#############################
menu_idioma() {
  printf "\n"
  printf "Escolha seu idioma / Choose your language / Elija su idioma / Choisissez votre langue / Scegli la tua lingua\n"
  printf "1) Português\n"
  printf "2) English\n"
  printf "3) Español\n"
  printf "4) Français\n"
  printf "5) Italiano\n"
  printf "\n"
  printf "Digite o número / Enter the number / Escriba el número / Entrez le numéro / Inserisci il numero\n"
  read -p "> " idioma
}

#########################################
# Definir mensagens no idioma escolhido #
#########################################
definir_mensagens() {
  case $idioma in
    1)
      # Português
      msg_passo1="Passo 1: Insira o seu e-mail para configurar o Let's Encrypt (certificado ssl) no Traefik:"
      msg_solicita_email="📧 Por favor, insira seu e-mail:"
      msg_email_valido="✅ Email válido: "
      msg_email_invalido="❌ Email inválido. Tente novamente."

      msg_passo2="Passo 2: Baixando Stack Traefik:"
      msg_baixando_stack="🔄 Substituindo o e-mail no arquivo..."
      msg_stack_ok="✅ Stack Traefik baixada e e-mail substituído com sucesso."
      msg_stack_erro="❌ Erro: Arquivo final da Stack Traefik está vazio ou não foi gerado corretamente."
      
      msg_passo3="Passo 3: Atualizando Repositórios"
      msg_repo_ok="✅ Repositórios atualizados com sucesso."
      msg_repo_erro="❌ Erro ao atualizar repositórios."

      msg_passo4="Passo 4: Verificando Chave GPG do Docker"
      msg_docker_chave_pular="⚠️ Chave GPG do Docker já existe. Pulando."
      msg_docker_chave_ok="✅ Chave GPG adicionada com sucesso."
      msg_docker_chave_erro="❌ Erro ao adicionar chave GPG."
      
      msg_passo5="Passo 5: Configurando Repositórios do Docker"
      msg_repositorio_docker_pular="⚠️ Repositórios do Docker já configurados. Pulando."
      msg_repositorio_docker_ok="✅ Repositórios do Docker configurados com sucesso."
      msg_repositorio_docker_erro="❌ Erro ao configurar repositórios do Docker."
      
      msg_passo6="Passo 6: Instalando Docker"
      msg_docker_ok="✅ Docker instalado com sucesso."
      msg_docker_erro="❌ Erro ao instalar o Docker."
      msg_docker_pular="⚠️ Docker já instalado. Pulando."
      
      msg_passo7="Passo 7: Configurando Docker para iniciar automaticamente"
      msg_docker_iniciar_automaticamente_pular="⚠️ Docker já configurado para iniciar automaticamente."
      msg_docker_iniciar_automaticamente_ok="✅ Serviço Docker configurado para iniciar automaticamente."

      msg_passo8="Passo 8: Obtendo IP da máquina"
      msg_obter_ip_erro="❌ Erro ao obter IP da máquina."
      msg_obter_ip_ok="✅ IP da máquina:"
      
      msg_passo9="Passo 9: Verificando Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm já inicializado. Pulando."
      msg_docker_swarm_ok="✅ Docker Swarm inicializado com sucesso."
      msg_docker_swarm_erro="❌ Erro ao inicializar Docker Swarm."

      msg_passo10="Passo 10: Verificando Rede 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ Rede 'network_swarm_public' já existe. Pulando."
      msg_docker_network_swarm_ok="✅ Rede 'network_swarm_public' criada com sucesso."
      msg_docker_network_swarm_erro="❌ Erro ao criar a rede."
      
      msg_passo11="Passo 11: Subindo Stack Traefik"
      msg_stack_traefik_ok="✅ Stack Traefik implantada com sucesso!"
      msg_stack_traefik_erro="❌ Erro ao implantar Stack Traefik."
      
      msg_script_executado_ok="🚀 Script executado com sucesso!"
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
      
      msg_passo3="Step 3: Updating Repositories"
      msg_repo_ok="✅ Repositories updated successfully."
      msg_repo_erro="❌ Error updating repositories."

      msg_passo4="Step 4: Checking Docker GPG Key"
      msg_docker_chave_pular="⚠️ Docker GPG key already exists. Skipping."
      msg_docker_chave_ok="✅ GPG key added successfully."
      msg_docker_chave_erro="❌ Error adding GPG key."
      
      msg_passo5="Step 5: Configuring Docker Repositories"
      msg_repositorio_docker_pular="⚠️ Docker repositories already configured. Skipping."
      msg_repositorio_docker_ok="✅ Docker repositories configured successfully."
      msg_repositorio_docker_erro="❌ Error configuring Docker repositories."
      
      msg_passo6="Step 6: Installing Docker"
      msg_docker_ok="✅ Docker installed successfully."
      msg_docker_erro="❌ Error installing Docker."
      msg_docker_pular="⚠️ Docker already installed. Skipping."
      
      msg_passo7="Step 7: Configuring Docker to start automatically"
      msg_docker_iniciar_automaticamente_pular="⚠️ Docker already set to start automatically."
      msg_docker_iniciar_automaticamente_ok="✅ Docker service set to start automatically."

      msg_passo8="Step 8: Obtaining machine IP"
      msg_obter_ip_erro="❌ Error obtaining machine IP."
      msg_obter_ip_ok="✅ Machine IP:"
      
      msg_passo9="Step 9: Checking Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm already initialized. Skipping."
      msg_docker_swarm_ok="✅ Docker Swarm initialized successfully."
      msg_docker_swarm_erro="❌ Error initializing Docker Swarm."

      msg_passo10="Step 10: Checking 'network_swarm_public' Network"
      msg_docker_network_swarm_pular="⚠️ 'network_swarm_public' already exists. Skipping."
      msg_docker_network_swarm_ok="✅ 'network_swarm_public' network created successfully."
      msg_docker_network_swarm_erro="❌ Error creating network."
      
      msg_passo11="Step 11: Deploying Traefik Stack"
      msg_stack_traefik_ok="✅ Traefik stack deployed successfully!"
      msg_stack_traefik_erro="❌ Error deploying Traefik stack."
      
      msg_script_executado_ok="🚀 Script executed successfully!"
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
      
      msg_passo3="Paso 3: Actualizando Repositorios"
      msg_repo_ok="✅ Repositorios actualizados correctamente."
      msg_repo_erro="❌ Error al actualizar repositorios."

      msg_passo4="Paso 4: Verificación de la Clave GPG de Docker"
      msg_docker_chave_pular="⚠️ La clave GPG de Docker ya existe. Omitiendo."
      msg_docker_chave_ok="✅ Clave GPG añadida correctamente."
      msg_docker_chave_erro="❌ Error al añadir la clave GPG."
      
      msg_passo5="Paso 5: Configurando los Repositorios de Docker"
      msg_repositorio_docker_pular="⚠️ Repositorios de Docker ya configurados. Omitiendo."
      msg_repositorio_docker_ok="✅ Repositorios de Docker configurados correctamente."
      msg_repositorio_docker_erro="❌ Error al configurar repositorios de Docker."
      
      msg_passo6="Paso 6: Instalando Docker"
      msg_docker_ok="✅ Docker instalado correctamente."
      msg_docker_erro="❌ Error al instalar Docker."
      msg_docker_pular="⚠️ Docker ya está instalado. Omitiendo."
      
      msg_passo7="Paso 7: Configurando Docker para que inicie automáticamente"
      msg_docker_iniciar_automaticamente_pular="⚠️ Docker ya está configurado para iniciar automáticamente."
      msg_docker_iniciar_automaticamente_ok="✅ Docker configurado para iniciar automáticamente."

      msg_passo8="Paso 8: Obteniendo la IP de la máquina"
      msg_obter_ip_erro="❌ Error al obtener la IP de la máquina."
      msg_obter_ip_ok="✅ IP de la máquina:"
      
      msg_passo9="Paso 9: Verificando Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm ya está inicializado. Omitiendo."
      msg_docker_swarm_ok="✅ Docker Swarm inicializado correctamente."
      msg_docker_swarm_erro="❌ Error al inicializar Docker Swarm."

      msg_passo10="Paso 10: Verificando la Red 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ La red 'network_swarm_public' ya existe. Omitiendo."
      msg_docker_network_swarm_ok="✅ Red 'network_swarm_public' creada correctamente."
      msg_docker_network_swarm_erro="❌ Error al crear la red."
      
      msg_passo11="Paso 11: Desplegando Stack Traefik"
      msg_stack_traefik_ok="✅ Stack Traefik desplegada correctamente!"
      msg_stack_traefik_erro="❌ Error al desplegar Stack Traefik."
      
      msg_script_executado_ok="🚀 ¡Script ejecutado correctamente!"
      ;;
    4)
      # Français
      msg_passo1="Étape 1: Entrez votre email pour configurer Let's Encrypt (certificat SSL) dans Traefik:"
      msg_solicita_email="📧 Veuillez entrer votre email:"
      msg_email_valido="✅ Email valide: "
      msg_email_invalido="❌ Email invalide. Veuillez réessayer."

      msg_passo2="Étape 2: Téléchargement de la Stack Traefik:"
      msg_baixando_stack="🔄 Remplacement de l'email dans le fichier..."
      msg_stack_ok="✅ Stack Traefik téléchargée et email remplacé avec succès."
      msg_stack_erro="❌ Erreur: Le fichier final de la Stack Traefik est vide ou non généré correctement."
      
      msg_passo3="Étape 3: Mise à jour des Référentiels"
      msg_repo_ok="✅ Référentiels mis à jour avec succès."
      msg_repo_erro="❌ Erreur lors de la mise à jour des référentiels."

      msg_passo4="Étape 4: Vérification de la Clé GPG de Docker"
      msg_docker_chave_pular="⚠️ La clé GPG Docker existe déjà. Passage."
      msg_docker_chave_ok="✅ Clé GPG ajoutée avec succès."
      msg_docker_chave_erro="❌ Erreur lors de l'ajout de la clé GPG."
      
      msg_passo5="Étape 5: Configuration des Référentiels Docker"
      msg_repositorio_docker_pular="⚠️ Les référentiels Docker sont déjà configurés. Passage."
      msg_repositorio_docker_ok="✅ Référentiels Docker configurés avec succès."
      msg_repositorio_docker_erro="❌ Erreur lors de la configuration des référentiels Docker."
      
      msg_passo6="Étape 6: Installation de Docker"
      msg_docker_ok="✅ Docker installé avec succès."
      msg_docker_erro="❌ Erreur lors de l'installation de Docker."
      msg_docker_pular="⚠️ Docker est déjà installé. Passage."
      
      msg_passo7="Étape 7: Configuration de Docker pour démarrer automatiquement"
      msg_docker_iniciar_automaticamente_pular="⚠️ Docker est déjà configuré pour démarrer automatiquement."
      msg_docker_iniciar_automaticamente_ok="✅ Docker configuré pour démarrer automatiquement."

      msg_passo8="Étape 8: Obtention de l'IP de la machine"
      msg_obter_ip_erro="❌ Erreur lors de l'obtention de l'IP de la machine."
      msg_obter_ip_ok="✅ IP de la machine:"
      
      msg_passo9="Étape 9: Vérification du Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm est déjà initialisé. Passage."
      msg_docker_swarm_ok="✅ Docker Swarm initialisé avec succès."
      msg_docker_swarm_erro="❌ Erreur lors de l'initialisation de Docker Swarm."

      msg_passo10="Étape 10: Vérification du Réseau 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ Le réseau 'network_swarm_public' existe déjà. Passage."
      msg_docker_network_swarm_ok="✅ Réseau 'network_swarm_public' créé avec succès."
      msg_docker_network_swarm_erro="❌ Erreur lors de la création du réseau."
      
      msg_passo11="Étape 11: Déploiement de la Stack Traefik"
      msg_stack_traefik_ok="✅ Stack Traefik déployée avec succès!"
      msg_stack_traefik_erro="❌ Erreur lors du déploiement de la Stack Traefik."
      
      msg_script_executado_ok="🚀 Script exécuté avec succès!"
      ;;
    5)
      # Italiano
      msg_passo1="Fase 1: Inserisci la tua email per configurare Let's Encrypt (certificato SSL) in Traefik:"
      msg_solicita_email="📧 Si prega di inserire la tua email:"
      msg_email_valido="✅ Email valido: "
      msg_email_invalido="❌ Email non valido. Riprova."

      msg_passo2="Fase 2: Scaricamento dello Stack Traefik:"
      msg_baixando_stack="🔄 Sostituendo l'email nel file..."
      msg_stack_ok="✅ Stack Traefik scaricato e email sostituito con successo."
      msg_stack_erro="❌ Errore: Il file finale dello Stack Traefik è vuoto o non generato correttamente."
      
      msg_passo3="Fase 3: Aggiornamento dei Repositori"
      msg_repo_ok="✅ Repositori aggiornati con successo."
      msg_repo_erro="❌ Errore durante l'aggiornamento dei repositori."

      msg_passo4="Fase 4: Verifica della Chiave GPG Docker"
      msg_docker_chave_pular="⚠️ Chiave GPG Docker già esistente. Salto."
      msg_docker_chave_ok="✅ Chiave GPG aggiunta con successo."
      msg_docker_chave_erro="❌ Errore durante l'aggiunta della chiave GPG."
      
      msg_passo5="Fase 5: Configurazione dei Repositori Docker"
      msg_repositorio_docker_pular="⚠️ Repositori Docker già configurati. Salto."
      msg_repositorio_docker_ok="✅ Repositori Docker configurati con successo."
      msg_repositorio_docker_erro="❌ Errore nella configurazione dei repositori Docker."
      
      msg_passo6="Fase 6: Installazione di Docker"
      msg_docker_ok="✅ Docker installato con successo."
      msg_docker_erro="❌ Errore durante l'installazione di Docker."
      msg_docker_pular="⚠️ Docker già installato. Salto."
      
      msg_passo7="Fase 7: Configurazione di Docker per l'avvio automatico"
      msg_docker_iniciar_automaticamente_pular="⚠️ Docker già configurato per l'avvio automatico."
      msg_docker_iniciar_automaticamente_ok="✅ Docker configurato per l'avvio automatico."

      msg_passo8="Fase 8: Ottenimento dell'IP della macchina"
      msg_obter_ip_erro="❌ Errore durante l'ottenimento dell'IP della macchina."
      msg_obter_ip_ok="✅ IP della macchina:"
      
      msg_passo9="Fase 9: Verifica Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm già inizializzato. Salto."
      msg_docker_swarm_ok="✅ Docker Swarm inizializzato con successo."
      msg_docker_swarm_erro="❌ Errore durante l'inizializzazione di Docker Swarm."

      msg_passo10="Fase 10: Verifica della Rete 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ Rete 'network_swarm_public' già esistente. Salto."
      msg_docker_network_swarm_ok="✅ Rete 'network_swarm_public' creata con successo."
      msg_docker_network_swarm_erro="❌ Errore nella creazione della rete."
      
      msg_passo11="Fase 11: Distribuzione dello Stack Traefik"
      msg_stack_traefik_ok="✅ Stack Traefik distribuito con successo!"
      msg_stack_traefik_erro="❌ Errore durante la distribuzione dello Stack Traefik."
      
      msg_script_executado_ok="🚀 Script eseguito con successo!"
      ;;
    *)
      echo "Opção inválida. Tente novamente. / Invalid option. Please try again. / Opción inválida. Inténtalo de nuevo. / Option invalide. Veuillez réessayer. / Opzione non valida. Riprova."
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

#############################
# Função para validar email #
#############################
validar_email() {
  local email="$1"
  if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0
  else
    return 1
  fi
}

##########################################
# Passo 1: Solicitar o e-mail do usuário #
##########################################
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
print_with_line "$msg_passo3"

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
print_with_line "$msg_passo4"

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
else
    echo "$msg_docker_chave_pular"
fi

if [ $? -eq 0 ]; then
    echo -e "$msg_docker_chave_ok"
else
    echo -e "$msg_docker_chave_erro"
    exit 1
fi

################################################
# Passo 5: Configurando Repositórios do Docker #
################################################
print_with_line "$msg_passo5"

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
else
    echo "$msg_repositorio_docker_pular"
fi

if [ $? -eq 0 ]; then
    echo -e "$msg_repositorio_docker_ok"
else
    echo -e "$msg_repositorio_docker_erro"
    exit 1
fi

############################
# Passo 6: Instalar Docker #
############################
print_with_line "$msg_passo6"

if ! command -v docker &> /dev/null; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    if [ $? -eq 0 ]; then
        echo -e "$msg_docker_ok"
    else
        echo -e "$msg_docker_erro"
        exit 1
    fi
else
    echo "$msg_docker_pular"
fi

###########################################################
# Passo 7: Configurar Docker para iniciar automaticamente #
###########################################################
print_with_line "$msg_passo7"

if systemctl is-enabled docker.service | grep -q "enabled"; then
    echo "$msg_docker_iniciar_automaticamente_pular"
else
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    echo "$msg_docker_iniciar_automaticamente_ok"
fi

##################################
# Passo 8: Obter o IP da máquina #
##################################
print_with_line "$msg_passo8"

IP_ADDR=$(hostname -I | awk '{print $1}')

if [ -z "$IP_ADDR" ]; then
    echo -e "$msg_obter_ip_erro"
    exit 1
else
    echo -e "$msg_obter_ip_ok $IP_ADDR"
fi

###########################################################
# Passo 9: Verificar se Docker Swarm já está inicializado #
###########################################################
print_with_line "$msg_passo9"

if docker info | grep -q "Swarm: active"; then
    echo "$msg_docker_swarm_pular"
else
    docker swarm init --advertise-addr=$IP_ADDR
    if [ $? -eq 0 ]; then
        echo -e "$msg_docker_swarm_ok"
    else
        echo -e "$msg_docker_swarm_erro"
        exit 1
    fi
fi

####################################
# Passo 10: Verificar/criar a rede #
####################################
print_with_line "$msg_passo10"

if docker network ls | grep -q "network_swarm_public"; then
    echo "$msg_docker_network_swarm_pular"
else
    docker network create --driver=overlay network_swarm_public
    if [ $? -eq 0 ]; then
        echo -e "$msg_docker_network_swarm_ok"
    else
        echo -e "$msg_docker_network_swarm_erro"
        exit 1
    fi
fi

####################################
# Passo 11: Subir stack do Traefik #
####################################
print_with_line "$msg_passo11"

docker stack deploy --prune --detach=false --resolve-image always -c stack-traefik-v2.yml traefik

if [ $? -eq 0 ]; then
    echo -e "$msg_stack_traefik_ok"
else
    echo -e "$msg_stack_traefik_erro"
    exit 1
fi

echo -e "\n$msg_script_executado_ok"
