#!/bin/bash

clear

#-------------------
# Valores pré-definido
#-------------------
SUBDOMINIO_PMA_DEFAULT="pma"
SUBDOMINIO_PORTAINER_DEFAULT="painel"
SUBDOMINIO_MAUTIC_DEFAULT="leadmanager"

#---------------------------
# Função para exibir o menu 
#---------------------------
menu_idioma() {
  printf "Escolha seu idioma / Choose your language / Elija su idioma / Choisissez votre langue / Scegli la tua lingua\n"
  printf "1) Português - Digite 1 e pressione ENTER\n"
  printf "2) English   - Enter 2 and press ENTER\n"
  printf "3) Español   - Escriba 3 y presione ENTER\n"
  printf "4) Français  - Entrez 4 et appuyez sur ENTER\n"
  printf "5) Italiano  - Inserisci 5 e premi INVIO\n"
  printf "\n"
  read -p "> " idioma
  echo ""
}

#----------------------------------------------------------
# Função para imprimir uma linha de caracteres com um texto
#----------------------------------------------------------
print_with_line() {
    local texto="$1"                     # O texto a ser exibido
    local tamanho=${#texto}              # Conta o número de caracteres na string
    
    # Verifica se um caractere foi passado como segundo parâmetro
    local caracter="$2"
    if [ -z "$caracter" ]; then
        caracter="="                     # Usa '=' como padrão
    fi

    # Repete o caractere pelo tamanho da string
    local repeticao=$(printf "%${tamanho}s" | tr " " "$caracter")

    echo "$repeticao"  # Exibe a linha de caracteres superior
    echo "$texto"      # Exibe o texto
    echo "$repeticao"  # Exibe a linha de caracteres inferior
}

#------------------------------
# Função para validar o domínio
#------------------------------
validar_dominio() {
  local dominio="$1"
  local regex='^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$'

  # Verifica se o domínio corresponde à regex
  if [[ $dominio =~ $regex ]]; then
    return 0
  else
    return 1
  fi
}

#---------------------------------
# Função para validar subdomínio
#---------------------------------
validar_subdominio() {
  local subdominio="$1"
  
  # Regex para validar subdomínio (permitir letras, números e hifens, sem começar ou terminar com hifens)
  local regex='^[a-zA-Z0-9]+([a-zA-Z0-9-]*[a-zA-Z0-9])?$'

  # Verifica se o subdomínio corresponde à regex
  if [[ $subdominio =~ $regex ]]; then
    return 0  # Subdomínio válido
  else
    return 1  # Subdomínio inválido
  fi
}

#--------------------------
# Função para validar email
#--------------------------
validar_email() {
  local email="$1"
  if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0
  else
    return 1
  fi
}

#--------------------------
# Função para validar senha
#--------------------------
validar_senha() {
  local senha="$1"
  if [[ ${#senha} -lt 8 ]] || 
     ! [[ "$senha" =~ [A-Za-z] ]] || 
     ! [[ "$senha" =~ [0-9] ]] || 
     ! [[ "$senha" =~ [\!\@\#\$\%\^\&\*\(\)\_\+\-=\{\}\[\]\;\:\'\"\<\>\,\.\/\?] ]]; then
    return 1
  fi
  return 0
}

#--------------------------------------
# Definir mensagens no idioma escolhido
#--------------------------------------
definir_mensagens() {
  case $idioma in
    1)
      # Português
      msg_dominio="Informe o domínio:"
      msg_dominio_solicitar="📧 Por favor, insira um domínio:"
      msg_dominio_valido="✅ Domínio válido:"
      msg_dominio_invalido="❌ Domínio inválido. Por favor, tente novamente."

      msg_subdominio_portainer="📧 Por favor, insira o subdomínio para acessar o Portainer:"
      msg_subdominio_pma="📧 Por favor, insira o subdomínio para acessar o phpMyAdmin:"
      msg_subdominio_mautic="📧 Por favor, insira o subdomínio para acessar o Mautic:"

      msg_subdominio_valido="✅ Subdomínio válido:"
      msg_subdominio_invalido="❌ Subdomínio inválido. Por favor, tente novamente."

      msg_mautic_obter_email="Insira o e-mail do administrador do Mautic:"
      msg_mautic_obter_senha="Insira a senha de administrador do Mautic:"

      msg_portainer_obter_senha="Insira a senha de administrador do Portainer:"

      msg_mysql_obter_senha="Insira a senha de administrador do MySql:"

      msg_senha_invalida="Senha válida."
      msg_senha_requisitos="Senha inválida. A senha deve ter pelo menos 8 caracteres, conter letras, números e pelo menos um caractere especial."

      msg_traefik_obter_email="Insira o seu e-mail para configurar o Let's Encrypt (certificado ssl) no Traefik:"
      
      msg_email_solicitar="📧 Por favor, insira seu e-mail:"
      msg_email_valido="✅ Email válido: "
      msg_email_invalido="❌ Email inválido. Tente novamente."

      msg_obter_stack_portainer="Baixando Stack Portainer:"
      msg_obter_stack_mysql="Baixando Stack MySql:"
      msg_obter_stack_pma="Baixando Stack phpMyAdmin:"
      msg_obter_stack_mautic="Baixando Stack Mautic:"

      msg_stack_ok="✅ Stack baixada e url substituída com sucesso."
      msg_stack_erro="❌ Erro: Arquivo final da Stack está vazio ou não foi gerado corretamente."

      msg_obter_stack_traefik="Baixando Stack Traefik:"
      msg_stack_traefik_ok="✅ Stack Traefik baixada e e-mail substituído com sucesso."
      msg_stack_traefik_erro="❌ Erro: Arquivo final da Stack Traefik está vazio ou não foi gerado corretamente."

      msg_repository="Atualizando Repositórios"
      msg_repository_ok="✅ Repositórios atualizados com sucesso."
      msg_repository_erro="❌ Erro ao atualizar repositórios."

      msg_docker_chave_gpg="Verificando Chave GPG do Docker"
      msg_docker_chave_gpg_pular="⚠️ Chave GPG do Docker já existe. Pulando."
      msg_docker_chave_gpg_ok="✅ Chave GPG adicionada com sucesso."
      msg_docker_chave_gpg_erro="❌ Erro ao adicionar chave GPG."

      msg_repositorio_docker="Configurando Repositórios do Docker"
      msg_repositorio_docker_pular="⚠️ Repositórios do Docker já configurados. Pulando."
      msg_repositorio_docker_ok="✅ Repositórios do Docker configurados com sucesso."
      msg_repositorio_docker_erro="❌ Erro ao configurar repositórios do Docker."

      msg_instalar_docker="Instalando Docker"
      msg_instalar_docker_ok="✅ Docker instalado com sucesso."
      msg_instalar_docker_erro="❌ Erro ao instalar o Docker."
      msg_instalar_docker_pular="⚠️ Docker já instalado. Pulando."

      msg_docker_init_auto="Configurando Docker para iniciar automaticamente"
      msg_docker_init_auto_pular="⚠️ Docker já configurado para iniciar automaticamente."
      msg_docker_init_auto_ok="✅ Serviço Docker configurado para iniciar automaticamente."

      msg_obter_ip="Obtendo IP da máquina"
      msg_obter_ip_erro="❌ Erro ao obter IP da máquina."
      msg_obter_ip_ok="✅ IP da máquina:"

      msg_docker_swarm="Verificando Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm já inicializado. Pulando."
      msg_docker_swarm_ok="✅ Docker Swarm inicializado com sucesso."
      msg_docker_swarm_erro="❌ Erro ao inicializar Docker Swarm."

      msg_docker_network_swarm="Verificando Rede 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ Rede 'network_swarm_public' já existe. Pulando."
      msg_docker_network_swarm_ok="✅ Rede 'network_swarm_public' criada com sucesso."
      msg_docker_network_swarm_erro="❌ Erro ao criar a rede."

      msg_stack_traefik_deploy="Subindo Stack Traefik"
      msg_stack_traefik_deploy_ok="✅ Stack Traefik implantada com sucesso!"
      msg_stack_traefik_deploy_erro="❌ Erro ao implantar Stack Traefik."

      msg_stack_portainer_deploy="Subindo Stack Portainer"
      msg_stack_portainer_deploy_ok="✅ Stack Portainer implantada com sucesso!"
      msg_stack_portainer_deploy_erro="❌ Erro ao implantar Stack Portainer."

      msg_script_executado_ok="🚀 Script executado com sucesso!"
      ;;
    2)
      # English
      msg_dominio="Enter the domain:"
      msg_dominio_solicitar="📧 Please enter a domain:"
      msg_dominio_valido="✅ Valid domain:"
      msg_dominio_invalido="❌ Invalid domain. Please try again."

      msg_subdominio_portainer="📧 Please enter the subdomain to access Portainer:"
      msg_subdominio_pma="📧 Please enter the subdomain to access phpMyAdmin:"
      msg_subdominio_mautic="📧 Please enter the subdomain to access Mautic:"

      msg_subdominio_valido="✅ Valid subdomain:"
      msg_subdominio_invalido="❌ Invalid subdomain. Please try again."

      msg_mautic_obter_email="Enter the Mautic administrator's email:"
      msg_mautic_obter_senha="Enter the Mautic administrator's password:"

      msg_portainer_obter_senha="Enter the Portainer administrator password:"

      msg_mysql_obter_senha="Enter the MySQL administrator password:"

      msg_senha_invalida="Valid password."
      msg_senha_requisitos="Invalid password. The password must be at least 8 characters long, contain letters, numbers, and at least one special character."

      msg_traefik_obter_email="Enter your email to configure Let's Encrypt (SSL certificate) in Traefik:"

      msg_email_solicitar="📧 Please enter your email:"
      msg_email_valido="✅ Valid email: "
      msg_email_invalido="❌ Invalid email. Please try again."

      msg_obter_stack_portainer="Downloading Portainer Stack:"
      msg_obter_stack_mysql="Downloading MySQL Stack:"
      msg_obter_stack_pma="Downloading phpMyAdmin Stack:"
      msg_obter_stack_mautic="Downloading Mautic Stack:"

      msg_stack_ok="✅ Portainer stack downloaded and url successfully replaced."
      msg_stack_erro="❌ Error: Final Portainer Stack file is empty or was not generated correctly."

      msg_obter_stack_traefik="Downloading Traefik Stack:"
      msg_stack_traefik_ok="✅ Traefik stack downloaded and email successfully replaced."
      msg_stack_traefik_erro="❌ Error: Final Traefik Stack file is empty or was not generated correctly."

      msg_repository="Updating Repositories"
      msg_repository_ok="✅ Repositories successfully updated."
      msg_repository_erro="❌ Error updating repositories."

      msg_docker_chave_gpg="Verifying Docker GPG Key"
      msg_docker_chave_gpg_pular="⚠️ Docker GPG key already exists. Skipping."
      msg_docker_chave_gpg_ok="✅ GPG key added successfully."
      msg_docker_chave_gpg_erro="❌ Error adding GPG key."

      msg_repositorio_docker="Configuring Docker Repositories"
      msg_repositorio_docker_pular="⚠️ Docker repositories already configured. Skipping."
      msg_repositorio_docker_ok="✅ Docker repositories configured successfully."
      msg_repositorio_docker_erro="❌ Error configuring Docker repositories."

      msg_instalar_docker="Installing Docker"
      msg_instalar_docker_ok="✅ Docker installed successfully."
      msg_instalar_docker_erro="❌ Error installing Docker."
      msg_instalar_docker_pular="⚠️ Docker already installed. Skipping."

      msg_docker_init_auto="Configuring Docker to start automatically"
      msg_docker_init_auto_pular="⚠️ Docker already configured to start automatically."
      msg_docker_init_auto_ok="✅ Docker service configured to start automatically."

      msg_obter_ip="Obtaining machine IP"
      msg_obter_ip_erro="❌ Error obtaining machine IP."
      msg_obter_ip_ok="✅ Machine IP:"

      msg_docker_swarm="Verifying Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm already initialized. Skipping."
      msg_docker_swarm_ok="✅ Docker Swarm initialized successfully."
      msg_docker_swarm_erro="❌ Error initializing Docker Swarm."

      msg_docker_network_swarm="Verifying 'network_swarm_public' Network"
      msg_docker_network_swarm_pular="⚠️ 'network_swarm_public' network already exists. Skipping."
      msg_docker_network_swarm_ok="✅ 'network_swarm_public' network created successfully."
      msg_docker_network_swarm_erro="❌ Error creating the network."

      msg_stack_traefik_deploy="Deploying Traefik Stack"
      msg_stack_traefik_deploy_ok="✅ Traefik Stack deployed successfully!"
      msg_stack_traefik_deploy_erro="❌ Error deploying Traefik Stack."

      msg_stack_portainer_deploy="Deploying Portainer Stack"
      msg_stack_portainer_deploy_ok="✅ Portainer stack deployed successfully!"
      msg_stack_portainer_deploy_erro="❌ Error deploying Portainer stack."

      msg_script_executado_ok="🚀 Script executed successfully!"
      ;;
    3)
      # Español
      msg_dominio="Introduzca el dominio:"
      msg_dominio_solicitar="📧 Por favor, introduzca un dominio:"
      msg_dominio_valido="✅ Dominio válido:"
      msg_dominio_invalido="❌ Dominio inválido. Por favor, intente nuevamente."

      msg_subdominio_portainer="📧 Por favor, ingrese el subdominio para acceder a Portainer:"
      msg_subdominio_pma="📧 Por favor, ingrese el subdominio para acceder a phpMyAdmin:"
      msg_subdominio_mautic="📧 Por favor, ingrese el subdominio para acceder a Mautic:"

      msg_subdominio_valido="✅ Subdominio válido:"
      msg_subdominio_invalido="❌ Subdominio inválido. Por favor, intente de nuevo."

      msg_mautic_obter_email="Ingrese el correo electrónico del administrador de Mautic:"
      msg_mautic_obter_senha="Ingrese la contraseña del administrador de Mautic:"

      msg_portainer_obter_senha="Ingrese la contraseña de administrador de Portainer:"

      msg_mysql_obter_senha="Ingrese la contraseña de administrador de MySQL:"

      msg_senha_invalida="Contraseña válida."
      msg_senha_requisitos="Contraseña inválida. La contraseña debe tener al menos 8 caracteres, contener letras, números y al menos un carácter especial."

      msg_traefik_obter_email="Introduzca su correo electrónico para configurar Let's Encrypt (certificado SSL) en Traefik:"
      
      msg_email_solicitar="📧 Por favor, introduzca su correo electrónico:"
      msg_email_valido="✅ Correo electrónico válido: "
      msg_email_invalido="❌ Correo electrónico inválido. Intente nuevamente."

      msg_obter_stack_portainer="Descargando la Stack de Portainer:"
      msg_obter_stack_mysql="Descargando Stack de MySQL:"
      msg_obter_stack_pma="Descargando Stack de phpMyAdmin:"
      msg_obter_stack_mautic="Descargando Stack de Mautic:"
      
      msg_stack_ok="✅ Stack de Portainer descargada y url reemplazado con éxito."
      msg_stack_erro="❌ Error: El archivo final de la Stack de Portainer está vacío o no se generó correctamente."

      msg_obter_stack_traefik="Descargando la Stack de Traefik:"
      msg_stack_traefik_ok="✅ Stack de Traefik descargada y correo electrónico reemplazado con éxito."
      msg_stack_traefik_erro="❌ Error: El archivo final de la Stack de Traefik está vacío o no se generó correctamente."

      msg_repository="Actualizando Repositorios"
      msg_repository_ok="✅ Repositorios actualizados con éxito."
      msg_repository_erro="❌ Error al actualizar los repositorios."

      msg_docker_chave_gpg="Verificando la Clave GPG de Docker"
      msg_docker_chave_gpg_pular="⚠️ La clave GPG de Docker ya existe. Saltando."
      msg_docker_chave_gpg_ok="✅ Clave GPG añadida con éxito."
      msg_docker_chave_gpg_erro="❌ Error al añadir la clave GPG."

      msg_repositorio_docker="Configurando Repositorios de Docker"
      msg_repositorio_docker_pular="⚠️ Los repositorios de Docker ya están configurados. Saltando."
      msg_repositorio_docker_ok="✅ Repositorios de Docker configurados con éxito."
      msg_repositorio_docker_erro="❌ Error al configurar los repositorios de Docker."

      msg_instalar_docker="Instalando Docker"
      msg_instalar_docker_ok="✅ Docker instalado con éxito."
      msg_instalar_docker_erro="❌ Error al instalar Docker."
      msg_instalar_docker_pular="⚠️ Docker ya está instalado. Saltando."

      msg_docker_init_auto="Configurando Docker para iniciar automáticamente"
      msg_docker_init_auto_pular="⚠️ Docker ya está configurado para iniciar automáticamente."
      msg_docker_init_auto_ok="✅ Servicio Docker configurado para iniciar automáticamente."

      msg_obter_ip="Obteniendo IP de la máquina"
      msg_obter_ip_erro="❌ Error al obtener la IP de la máquina."
      msg_obter_ip_ok="✅ IP de la máquina:"

      msg_docker_swarm="Verificando Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm ya está inicializado. Saltando."
      msg_docker_swarm_ok="✅ Docker Swarm inicializado con éxito."
      msg_docker_swarm_erro="❌ Error al inicializar Docker Swarm."

      msg_docker_network_swarm="Verificando la Red 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ La red 'network_swarm_public' ya existe. Saltando."
      msg_docker_network_swarm_ok="✅ Red 'network_swarm_public' creada con éxito."
      msg_docker_network_swarm_erro="❌ Error al crear la red."

      msg_stack_traefik_deploy="Desplegando la Stack de Traefik"
      msg_stack_traefik_deploy_ok="✅ Stack de Traefik desplegada con éxito!"
      msg_stack_traefik_deploy_erro="❌ Error al desplegar la Stack de Traefik."

      msg_stack_portainer_deploy="Desplegando Stack Portainer"
      msg_stack_portainer_deploy_ok="✅ Stack Portainer desplegada con éxito!"
      msg_stack_portainer_deploy_erro="❌ Error al desplegar Stack Portainer."

      msg_script_executado_ok="🚀 ¡Script ejecutado con éxito!"
      ;;
    4)
      # Français
      msg_dominio="Veuillez saisir le domaine :"
      msg_dominio_solicitar="📧 Veuillez saisir un domaine :"
      msg_dominio_valido="✅ Domaine valide :"
      msg_dominio_invalido="❌ Domaine invalide. Veuillez réessayer."

      msg_subdominio_portainer="📧 Veuillez entrer le sous-domaine pour accéder à Portainer :"
      msg_subdominio_pma="📧 Veuillez entrer le sous-domaine pour accéder à phpMyAdmin :"
      msg_subdominio_mautic="📧 Veuillez entrer le sous-domaine pour accéder à Mautic :"

      msg_subdominio_valido="✅ Sous-domaine valide :"
      msg_subdominio_invalido="❌ Sous-domaine invalide. Veuillez réessayer."

      msg_mautic_obter_email="Entrez l'e-mail de l'administrateur de Mautic:"
      msg_mautic_obter_senha="Entrez le mot de passe de l'administrateur de Mautic:"

      msg_portainer_obter_senha="Entrez le mot de passe administrateur de Portainer :"

      msg_mysql_obter_senha="Entrez le mot de passe administrateur de MySQL :"

      msg_senha_invalida="Mot de passe valide."
      msg_senha_requisitos="Mot de passe invalide. Le mot de passe doit comporter au moins 8 caractères, contenir des lettres, des chiffres et au moins un caractère spécial."

      msg_traefik_obter_email="Veuillez saisir votre e-mail pour configurer Let's Encrypt (certificat SSL) sur Traefik :"
      
      msg_email_solicitar="📧 Veuillez saisir votre e-mail :"
      msg_email_valido="✅ E-mail valide : "
      msg_email_invalido="❌ E-mail invalide. Veuillez réessayer."

      msg_obter_stack_portainer="Téléchargement de la Stack Portainer :"
      msg_obter_stack_mysql="Téléchargement de la Stack MySQL :"
      msg_obter_stack_pma="Téléchargement de la Stack phpMyAdmin :"
      msg_obter_stack_mautic="Téléchargement de la Stack Mautic :"
      
      msg_stack_ok="✅ Stack Portainer téléchargée et url remplacé avec succès."
      msg_stack_erro="❌ Erreur : Le fichier final de la Stack Portainer est vide ou n'a pas été généré correctement."

      msg_obter_stack_traefik="Téléchargement de la Stack Traefik :"
      msg_stack_traefik_ok="✅ Stack Traefik téléchargée et e-mail remplacé avec succès."
      msg_stack_traefik_erro="❌ Erreur : Le fichier final de la Stack Traefik est vide ou n'a pas été généré correctement."

      msg_repository="Mise à jour des dépôts"
      msg_repository_ok="✅ Dépôts mis à jour avec succès."
      msg_repository_erro="❌ Erreur lors de la mise à jour des dépôts."

      msg_docker_chave_gpg="Vérification de la clé GPG de Docker"
      msg_docker_chave_gpg_pular="⚠️ La clé GPG de Docker existe déjà. Ignorer."
      msg_docker_chave_gpg_ok="✅ Clé GPG ajoutée avec succès."
      msg_docker_chave_gpg_erro="❌ Erreur lors de l'ajout de la clé GPG."

      msg_repositorio_docker="Configuration des dépôts Docker"
      msg_repositorio_docker_pular="⚠️ Les dépôts Docker sont déjà configurés. Ignorer."
      msg_repositorio_docker_ok="✅ Dépôts Docker configurés avec succès."
      msg_repositorio_docker_erro="❌ Erreur lors de la configuration des dépôts Docker."

      msg_instalar_docker="Installation de Docker"
      msg_instalar_docker_ok="✅ Docker installé avec succès."
      msg_instalar_docker_erro="❌ Erreur lors de l'installation de Docker."
      msg_instalar_docker_pular="⚠️ Docker est déjà installé. Ignorer."

      msg_docker_init_auto="Configuration de Docker pour démarrer automatiquement"
      msg_docker_init_auto_pular="⚠️ Docker est déjà configuré pour démarrer automatiquement."
      msg_docker_init_auto_ok="✅ Service Docker configuré pour démarrer automatiquement."

      msg_obter_ip="Obtention de l'IP de la machine"
      msg_obter_ip_erro="❌ Erreur lors de l'obtention de l'IP de la machine."
      msg_obter_ip_ok="✅ IP de la machine :"

      msg_docker_swarm="Vérification de Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm est déjà initialisé. Ignorer."
      msg_docker_swarm_ok="✅ Docker Swarm initialisé avec succès."
      msg_docker_swarm_erro="❌ Erreur lors de l'initialisation de Docker Swarm."

      msg_docker_network_swarm="Vérification du Réseau 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ Le réseau 'network_swarm_public' existe déjà. Ignorer."
      msg_docker_network_swarm_ok="✅ Réseau 'network_swarm_public' créé avec succès."
      msg_docker_network_swarm_erro="❌ Erreur lors de la création du réseau."

      msg_stack_traefik_deploy="Déploiement de la Stack Traefik"
      msg_stack_traefik_deploy_ok="✅ Stack Traefik déployée avec succès !"
      msg_stack_traefik_deploy_erro="❌ Erreur lors du déploiement de la Stack Traefik."

      msg_stack_portainer_deploy="Déploiement de la Stack Portainer"
      msg_stack_portainer_deploy_ok="✅ Stack Portainer déployée avec succès !"
      msg_stack_portainer_deploy_erro="❌ Erreur lors du déploiement de la Stack Portainer."

      msg_script_executado_ok="🚀 Script exécuté avec succès !"
      ;;
    5)
      # Italiano
      msg_dominio="Inserisci il dominio:"
      msg_dominio_solicitar="📧 Per favore, inserisci un dominio:"
      msg_dominio_valido="✅ Dominio valido:"
      msg_dominio_invalido="❌ Dominio non valido. Per favore, riprova."

      msg_subdominio_portainer="📧 Per favore, inserisci il sottodominio per accedere a Portainer:"
      msg_subdominio_pma="📧 Per favore, inserisci il sottodominio per accedere a phpMyAdmin:"
      msg_subdominio_mautic="📧 Per favore, inserisci il sottodominio per accedere a Mautic:"

      msg_subdominio_valido="✅ Sottodominio valido:"
      msg_subdominio_invalido="❌ Sottodominio non valido. Per favore, riprova."

      msg_mautic_obter_email="Inserisci l'e-mail dell'amministratore di Mautic:"
      msg_mautic_obter_senha="Inserisci la password dell'amministratore di Mautic:"

      msg_portainer_obter_senha="Inserisci la password di amministratore di Portainer:"

      msg_mysql_obter_senha="Inserisci la password di amministratore di MySQL:"

      msg_senha_invalida="Password valida."
      msg_senha_requisitos="Password non valida. La password deve avere almeno 8 caratteri, contenere lettere, numeri e almeno un carattere speciale."

      msg_traefik_obter_email="Inserisci la tua email per configurare Let's Encrypt (certificato SSL) su Traefik:"
      
      msg_email_solicitar="📧 Per favore, inserisci la tua email:"
      msg_email_valido="✅ Email valida: "
      msg_email_invalido="❌ Email non valida. Riprova."

      msg_obter_stack_portainer="Scaricamento della Stack Portainer:"
      msg_obter_stack_mysql="Scaricamento Stack MySQL:"
      msg_obter_stack_pma="Scaricamento Stack phpMyAdmin:"
      msg_obter_stack_mautic="Scaricamento Stack Mautic:"
      
      msg_stack_ok="✅ Stack Portainer scaricata e url sostituita con successo."
      msg_stack_erro="❌ Errore: Il file finale della Stack Portainer è vuoto o non è stato generato correttamente."

      msg_obter_stack_traefik="Scaricamento della Stack Traefik:"
      msg_stack_traefik_ok="✅ Stack Traefik scaricata e email sostituita con successo."
      msg_stack_traefik_erro="❌ Errore: Il file finale della Stack Traefik è vuoto o non è stato generato correttamente."

      msg_repository="Aggiornamento dei repository"
      msg_repository_ok="✅ Repository aggiornati con successo."
      msg_repository_erro="❌ Errore durante l'aggiornamento dei repository."

      msg_docker_chave_gpg="Verifica della chiave GPG di Docker"
      msg_docker_chave_gpg_pular="⚠️ La chiave GPG di Docker esiste già. Saltando."
      msg_docker_chave_gpg_ok="✅ Chiave GPG aggiunta con successo."
      msg_docker_chave_gpg_erro="❌ Errore nell'aggiunta della chiave GPG."

      msg_repositorio_docker="Configurazione dei repository di Docker"
      msg_repositorio_docker_pular="⚠️ I repository di Docker sono già configurati. Saltando."
      msg_repositorio_docker_ok="✅ Repository di Docker configurati con successo."
      msg_repositorio_docker_erro="❌ Errore nella configurazione dei repository di Docker."

      msg_instalar_docker="Installazione di Docker"
      msg_instalar_docker_ok="✅ Docker installato con successo."
      msg_instalar_docker_erro="❌ Errore durante l'installazione di Docker."
      msg_instalar_docker_pular="⚠️ Docker è già installato. Saltando."

      msg_docker_init_auto="Configurazione di Docker per avviarsi automaticamente"
      msg_docker_init_auto_pular="⚠️ Docker è già configurato per avviarsi automaticamente."
      msg_docker_init_auto_ok="✅ Servizio Docker configurato per avviarsi automaticamente."

      msg_obter_ip="Ottenimento dell'IP della macchina"
      msg_obter_ip_erro="❌ Errore durante l'ottenimento dell'IP della macchina."
      msg_obter_ip_ok="✅ IP della macchina:"

      msg_docker_swarm="Verifica di Docker Swarm"
      msg_docker_swarm_pular="⚠️ Docker Swarm è già inizializzato. Saltando."
      msg_docker_swarm_ok="✅ Docker Swarm inizializzato con successo."
      msg_docker_swarm_erro="❌ Errore durante l'inizializzazione di Docker Swarm."

      msg_docker_network_swarm="Verifica della rete 'network_swarm_public'"
      msg_docker_network_swarm_pular="⚠️ La rete 'network_swarm_public' esiste già. Saltando."
      msg_docker_network_swarm_ok="✅ Rete 'network_swarm_public' creata con successo."
      msg_docker_network_swarm_erro="❌ Errore nella creazione della rete."

      msg_stack_traefik_deploy="Avvio della Stack Traefik"
      msg_stack_traefik_deploy_ok="✅ Stack Traefik avviata con successo!"
      msg_stack_traefik_deploy_erro="❌ Errore nell'avvio della Stack Traefik."

      msg_stack_portainer_deploy="Esecuzione della Stack Portainer"
      msg_stack_portainer_deploy_ok="✅ Stack Portainer eseguita con successo!"
      msg_stack_portainer_deploy_erro="❌ Errore durante l'esecuzione della Stack Portainer."

      msg_script_executado_ok="🚀 Script eseguito con successo!"
      ;;
    *)
      echo "Português: Opção inválida. Tente novamente."
      echo "English: Invalid option. Please try again."
      echo "Español: Opción inválida. Inténtalo de nuevo."
      echo "Français: Option invalide. Veuillez réessayer."
      echo "Italiano: Opzione non valida. Riprova."
      echo ""
      return 1
      ;;
  esac
  return 0
}

#-------------------------------------
# Loop para garantir escolha do idioma
#-------------------------------------
while true; do
  menu_idioma
  if definir_mensagens; then
    break
  fi
done

##################################
# Solicitar o domínio ao usuário #
##################################
print_with_line "$msg_dominio"

#------------------------------------------
# Loop para garantir a definição do domínio
#------------------------------------------
while true; do
  echo -e "$msg_dominio_solicitar"
  read -p "> " DOMINIO
  if validar_dominio "$DOMINIO"; then
    echo ""
    print_with_line "$msg_dominio_valido $DOMINIO" "-"
    echo ""
    break
  else
    echo -e "$msg_dominio_invalido"
    echo ""
  fi
done

#################################
# Solicitar o e-mail do traefik #
#################################
print_with_line "$msg_traefik_obter_email"

while true; do
  echo -e "$msg_email_solicitar"
  read -p "> " CHANGE_EMAIL_TRAEFIK
  echo # Para nova linha
  if validar_email "$CHANGE_EMAIL_TRAEFIK"; then
    print_with_line "$msg_email_valido $CHANGE_EMAIL_TRAEFIK" "-"
    echo ""
    break
  else
    echo -e "$msg_email_invalido"
    echo ""
  fi
done

#----------------------------------------------------------
# Loop para garantir a definição do subdominio do Portainer
#----------------------------------------------------------
while true; do
  echo -e "$msg_subdominio_portainer\n"
  # Exibe o valor padrão e permite edição
  read -e -p "> " -i "$SUBDOMINIO_PORTAINER_DEFAULT" SUBDOMINIO_PORTAINER
  if validar_subdominio "$SUBDOMINIO_PORTAINER"; then
    echo ""
    print_with_line "$msg_subdominio_valido $SUBDOMINIO_PORTAINER" "-"
    break
  else
    echo -e "$msg_subdominio_invalido"
    echo ""
  fi
done

############################################
# Solicitar a senha do Admin do Portainer  #
############################################
print_with_line "$msg_portainer_obter_senha"

while true; do
  echo -e "\n$msg_senha_solicitar"
  read -s -p "> " CHANGE_PORTAINER_ADMIN_PASSWORD
  echo # Para nova linha
  if validar_senha "$CHANGE_PORTAINER_ADMIN_PASSWORD"; then
    echo -e "\n$msg_senha_invalida"
    echo "----------------"
    break
  else
    echo -e "$msg_senha_requisitos"
  fi
done

#######################################
# Solicitar a senha do Admin do MySql #
#######################################
print_with_line "$msg_mysql_obter_senha"

while true; do
  echo -e "\n$msg_senha_solicitar"
  # Exibe a senha do portainer e permite edição
  read -e -p "> " -i "$CHANGE_PORTAINER_ADMIN_PASSWORD" CHANGE_MYSQL_ROOT_PASSWORD
  echo # Para nova linha
  if validar_senha "$CHANGE_MYSQL_ROOT_PASSWORD"; then
    echo -e "\n$msg_senha_invalida"
    echo "----------------"
    break
  else
    echo -e "$msg_senha_requisitos"
  fi
done

#-----------------------------------------------------------
# Loop para garantir a definição do subdominio do phpMyAdmin
#-----------------------------------------------------------
while true; do
  echo -e "$msg_subdominio_pma\n"
  # Exibe o valor padrão e permite edição
  read -e -p "> " -i "$SUBDOMINIO_PMA_DEFAULT" SUBDOMINIO_PMA
  if validar_subdominio "$SUBDOMINIO_PMA"; then
    echo ""
    print_with_line "$msg_subdominio_valido $SUBDOMINIO_PMA" "-"
    break
  else
    echo -e "$msg_subdominio_invalido"
    echo ""
  fi
done

#-------------------------------------------------------
# Loop para garantir a definição do subdominio do Mautic
#-------------------------------------------------------
while true; do
  echo -e "$msg_subdominio_mautic\n"
  # Exibe o valor padrão e permite edição
  read -e -p "> " -i "$SUBDOMINIO_MAUTIC_DEFAULT" SUBDOMINIO_MAUTIC
  if validar_subdominio "$SUBDOMINIO_MAUTIC"; then
    echo ""
    print_with_line "$msg_subdominio_valido $SUBDOMINIO_MAUTIC" "-"
    break
  else
    echo -e "$msg_subdominio_invalido"
    echo ""
  fi
done

#########################################
# Solicitar o e-mail do Admin do Mautic #
#########################################
print_with_line "$msg_mautic_obter_email"

while true; do
  echo -e "\n$msg_email_solicitar"
  # Exibe o e-mail escolhido para o traefik e permite edição
  read -e -p "> " -i "$CHANGE_EMAIL_TRAEFIK" CHANGE_MAUTIC_ADMIN_EMAIL
  if validar_email "$CHANGE_MAUTIC_ADMIN_EMAIL"; then
    echo -e "\n$msg_email_valido $CHANGE_MAUTIC_ADMIN_EMAIL"
    echo "----------------"
    break
  else
    echo -e "$msg_email_invalido"
  fi
done

#########################################
# Solicitar a senha do Admin do Mautic  #
#########################################
print_with_line "$msg_mautic_obter_senha"

while true; do
  echo -e "\n$msg_senha_solicitar"
  # Exibe a senha do MySql e permite edição
  read -e -p "> " -i "$CHANGE_MYSQL_ROOT_PASSWORD" CHANGE_MAUTIC_ADMIN_PASSWORD
  echo # Para nova linha
  if validar_senha "$CHANGE_MAUTIC_ADMIN_PASSWORD"; then
    echo -e "\n$msg_senha_invalida"
    echo "----------------"
    break
  else
    echo -e "$msg_senha_requisitos"
  fi
done

########################
# Baixar stack Traefik #
########################
print_with_line "$msg_obter_stack_traefik"

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-traefik-v2.yml | sed "s/CHANGE_EMAIL_TRAEFIK/${CHANGE_EMAIL_TRAEFIK}/g" > stack-traefik-v2.yml

if [[ -s stack-traefik-v2.yml ]]; then
  echo -e "$msg_stack_traefik_ok"
else
  echo -e "$msg_stack_traefik_erro"
  exit 1
fi

##########################
# Baixar stack Portainer #
##########################
print_with_line "$msg_obter_stack_portainer"

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-portainer.yml | sed "s/CHANGE_URL_PORTAINER/${SUBDOMINIO_PORTAINER}.${DOMINIO}/g" > stack-portainer.yml

if [[ -s stack-portainer.yml ]]; then
  echo -e "$msg_stack_ok"
else
  echo -e "$msg_stack_erro"
  exit 1
fi

######################
# Baixar stack MySql #
######################
print_with_line "$msg_obter_stack_mysql"

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-mysql-mautic.yml | sed "s/CHANGE_MYSQL_ROOT_PASSWORD/${CHANGE_MYSQL_ROOT_PASSWORD}/g" > stack-mysql-mautic.yml

if [[ -s stack-mysql-mautic.yml ]]; then
  echo -e "$msg_stack_ok"
else
  echo -e "$msg_stack_erro"
  exit 1
fi

###########################
# Baixar stack phpMyAdmin #
###########################
print_with_line "$msg_obter_stack_pma"

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-pma.yml | sed "s/CHANGE_URL_PMA/${SUBDOMINIO_PMA}.${DOMINIO}/g" > stack-pma.yml

if [[ -s stack-pma.yml ]]; then
  echo -e "$msg_stack_ok"
else
  echo -e "$msg_stack_erro"
  exit 1
fi

#######################
# Baixar stack Mautic #
#######################
print_with_line "$msg_obter_stack_mautic"

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-mautic.yml \
| sed -e "s/CHANGE_URL_MAUTIC/${SUBDOMINIO_MAUTIC}.${DOMINIO}/g" \
      -e "s/CHANGE_MYSQL_ROOT_PASSWORD/${CHANGE_MYSQL_ROOT_PASSWORD}/g" \
      -e "s/CHANGE_MAUTIC_ADMIN_EMAIL/${CHANGE_MAUTIC_ADMIN_EMAIL}/g" \
      -e "s/CHANGE_MAUTIC_ADMIN_PASSWORD/${CHANGE_MAUTIC_ADMIN_PASSWORD}/g" > stack-mautic.yml

if [[ -s stack-mautic.yml ]]; then
  echo -e "$msg_stack_pma_ok"
else
  echo -e "$msg_stack_erro"
  exit 1
fi

#######################
# Update repositórios #
#######################
print_with_line "$msg_repository"

apt-get update && apt install -y sudo gnupg2 wget ca-certificates apt-transport-https curl gnupg nano htop

if [ $? -eq 0 ]; then
    echo -e "$msg_repository_ok"
else
    echo -e "$msg_repository_erro"
    exit 1
fi

#################################
# Verificar chave GPG do Docker #
#################################
print_with_line "$msg_docker_chave_gpg"

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
else
    echo "$msg_docker_chave_gpg_pular"
fi

if [ $? -eq 0 ]; then
    echo -e "$msg_docker_chave_gpg_ok"
else
    echo -e "$msg_docker_chave_gpg_erro"
    exit 1
fi

#######################################
# Configurando Repositórios do Docker #
#######################################
print_with_line "$msg_repositorio_docker"

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

###################
# Instalar Docker #
###################
print_with_line "$msg_instalar_docker"

if ! command -v docker &> /dev/null; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    if [ $? -eq 0 ]; then
        echo -e "$msg_instalar_docker_ok"
    else
        echo -e "$msg_instalar_docker_erro"
        exit 1
    fi
else
    echo "$msg_instalar_docker_pular"
fi

##################################################
# Configurar Docker para iniciar automaticamente #
##################################################
print_with_line "$msg_docker_init_auto"

if systemctl is-enabled docker.service | grep -q "enabled"; then
    echo "$msg_docker_init_auto_pular"
else
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    echo "$msg_docker_init_auto_ok"
fi

#########################
# Obter o IP da máquina #
#########################
print_with_line "$msg_obter_ip"

IP_ADDR=$(hostname -I | awk '{print $1}')

if [ -z "$IP_ADDR" ]; then
    echo -e "$msg_obter_ip_erro"
    exit 1
else
    echo -e "$msg_obter_ip_ok $IP_ADDR"
fi

##################################################
# Verificar se Docker Swarm já está inicializado #
##################################################
print_with_line "$msg_docker_swarm"

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

##########################
# Verificar/criar a rede #
##########################
print_with_line "$msg_docker_network_swarm"

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

##########################
# Subir stack do Traefik #
##########################
print_with_line "$msg_stack_traefik_deploy"

docker stack deploy --prune --detach=false --resolve-image always -c stack-traefik-v2.yml traefik

if [ $? -eq 0 ]; then
    echo -e "$msg_stack_traefik_deploy_ok"
else
    echo -e "$msg_stack_traefik_deploy_erro"
    exit 1
fi

############################
# Subir stack do Portainer #
############################
print_with_line "$msg_stack_portainer_deploy"

docker stack deploy --prune --detach=false --resolve-image always -c stack-portainer.yml portainer

if [ $? -eq 0 ]; then
    echo -e "$msg_stack_portainer_deploy_ok"
else
    echo -e "$msg_stack_portainer_deploy_erro"
    exit 1
fi

echo -e "\n$msg_script_executado_ok"
