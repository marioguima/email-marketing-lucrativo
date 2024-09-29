#!/bin/bash

VERSION="v0.1.5"

MODE=$1

clear

# Função para formatar o texto com cor e estilo
format_multi_part_text() {
    # Cada argumento consiste em "texto;cor;estilo;background"
    for arg in "$@"; do
        IFS=";" read -r text color style background <<<"$arg"

        # Aplicando as cores de texto
        case $color in
        "red") color_code="31" ;;
        "green") color_code="32" ;;
        "yellow") color_code="33" ;;
        "blue") color_code="34" ;;
        "purple") color_code="35" ;;
        "cyan") color_code="36" ;;
        "white") color_code="37" ;;
        "default") color_code="39" ;;
        *) color_code="39" ;; # Cor padrão
        esac

        # Aplicando os estilos
        case $style in
        "bold") style_code="1" ;;
        "underline") style_code="4" ;;
        "italic") style_code="3" ;;
        "default") style_code="0" ;;
        *) style_code="0" ;; # Estilo padrão
        esac

        # Aplicando as cores de fundo
        case $background in
        "red") bg_code="41" ;;
        "green") bg_code="42" ;;
        "yellow") bg_code="43" ;;
        "blue") bg_code="44" ;;
        "purple") bg_code="45" ;;
        "cyan") bg_code="46" ;;
        "white") bg_code="47" ;;
        "default") bg_code="49" ;;
        *) bg_code="49" ;; # Cor de fundo padrão
        esac

        # Exibindo o texto com formatação
        echo -ne "\e[${style_code};${color_code};${bg_code}m${text}\e[0m"
    done
}

format_multi_part_text "$(date +"%d/%m/%Y") $(date +"%H:%M:%S") - ;cyan;default;default" "$VERSION\n;yellow;bold;default"
echo ""
echo ""

# Função para logar saídas somente no modo DEBUG
#-----------------------------------------------
debug_log() {
    if [[ "$MODE" == "DEBUG" ]]; then
        local log_content=$1

        # Verifica se o conteúdo é JSON
        if echo "$log_content" | jq . >/dev/null 2>&1; then
            # Formata a saída com jq
            echo "$log_content" | jq .
        else
            # Usa echo -e para permitir a interpretação de sequências de escape
            # echo -e "$log_content"
            format_multi_part_text "$log_content"
        fi
    fi
}

debug_log "DEBUG\n\n;red;bold;default"

# Valores pré-definido
#-------------------
SUBDOMINIO_PMA_DEFAULT="pma"
SUBDOMINIO_PORTAINER_DEFAULT="painel"
SUBDOMINIO_MAUTIC_DEFAULT="leadmanager"
PORTAINER_URL_LOCAL_API="http://localhost:9000"

# Função para exibir o menu
#---------------------------
menu_idioma() {
    format_multi_part_text "🌍 Escolha seu idioma / Choose your language / Elija su idioma / Choisissez votre langue / Scegli la tua lingua\n\n;cyan;bold;default"
    format_multi_part_text "1;yellow;default;default" " - Português\n;white;default;default"
    format_multi_part_text "2;yellow;default;default" " - English\n;white;default;default"
    format_multi_part_text "3;yellow;default;default" " - Español\n;white;default;default"
    format_multi_part_text "4;yellow;default;default" " - Français\n;white;default;default"
    format_multi_part_text "5;yellow;default;default" " - Italiano\n;white;default;default"
    echo ""
    read -p "> " idioma
    echo ""
}

# Função para ajustar o fuso horário
ajustar_fuso_horario() {
    case $1 in
    1)
        # Português - São Paulo
        new_timezone="America/Sao_Paulo"
        ;;
    2)
        # English - New York
        new_timezone="America/New_York"
        ;;
    3)
        # Español - Madrid
        new_timezone="Europe/Madrid"
        ;;
    4)
        # Français - Paris
        new_timezone="Europe/Paris"
        ;;
    5)
        # Italiano - Roma
        new_timezone="Europe/Rome"
        ;;
    *)
        echo "Opção inválida."
        return 1
        ;;
    esac

    # Mostrar o horário atual e o novo horário
    eval echo "$msg_horario_atual"
    eval echo "$msg_novo_horario"

    # Pergunta se o usuário deseja ajustar
    while true; do
        read -e -p "$(eval echo $msg_ajuste_horario_confirmacao)" confirm
        case $confirm in
        [SsYyOo]*)
            sudo timedatectl set-timezone $new_timezone
            eval echo "$msg_fuso_horario_ajustado"
            break
            ;;
        [Nn]*)
            echo "$msg_ajuste_horario_cancelado"
            break
            ;;
        *)
            echo "$msg_ajuste_horario_resposta_sn"
            ;;
        esac
    done
}

# Função para imprimir uma linha de caracteres com um texto
#----------------------------------------------------------
print_with_line() {
    local texto="$1"        # O texto a ser exibido
    local formato="$2"      # Formato para a ser utilizado
    local tamanho=${#texto} # Conta o número de caracteres na string

    # Verifica se um caractere foi passado como terceiro parâmetro
    local caracter="$3"
    if [ -z "$caracter" ]; then
        caracter="-" # Usa '-' como padrão
    fi

    # Repete o caractere pelo tamanho da string
    local repeticao=$(printf "%${tamanho}s" | tr " " "$caracter")

    # echo "$repeticao" # Exibe a linha de caracteres superior
    # echo -e "$texto"  # Exibe o texto
    # echo "$repeticao" # Exibe a linha de caracteres inferior
    format_multi_part_text "$texto\n;$formato"
    format_multi_part_text "$repeticao\n;$formato"
}

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

# Função para validar subdomínio
#---------------------------------
validar_subdominio() {
    local subdominio="$1"

    # Regex para validar subdomínio (permitir letras, números e hifens, sem começar ou terminar com hifens)
    local regex='^[a-zA-Z0-9]+([a-zA-Z0-9-]*[a-zA-Z0-9])?$'

    # Verifica se o subdomínio corresponde à regex
    if [[ $subdominio =~ $regex ]]; then
        return 0 # Subdomínio válido
    else
        return 1 # Subdomínio inválido
    fi
}

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

# Função para validar senha
#--------------------------
validar_senha() {
    local senha="$1"
    local valid=true # Assume que a senha é válida inicialmente
    local output=""  # Variável para armazenar as mensagens de requisitos

    # Verifica cada requisito e adiciona o emoji de sucesso ou erro antes da mensagem
    if [[ ${#senha} -ge 8 ]]; then
        output+="✅ $msg_senha_requisito_min_caracteres\n"
    else
        output+="❌ $msg_senha_requisito_min_caracteres\n"
        valid=false
    fi

    if [[ "$senha" =~ [A-Za-z] ]]; then
        output+="✅ $msg_senha_requisito_letra\n"
    else
        output+="❌ $msg_senha_requisito_letra\n"
        valid=false
    fi

    if [[ "$senha" =~ [0-9] ]]; then
        output+="✅ $msg_senha_requisito_numero\n"
    else
        output+="❌ $msg_senha_requisito_numero\n"
        valid=false
    fi

    # Verifica se contém ao menos um caractere especial permitido: ! @ # $ % & *
    if [[ "$senha" =~ [\!\@\#\$\%\&\*] ]]; then
        output+="✅ $msg_senha_requisito_especial\n"
    else
        output+="❌ $msg_senha_requisito_especial\n"
        valid=false
    fi

    # Se a senha não atender a algum requisito, exibe a mensagem de senha inválida
    if [ "$valid" = false ]; then
        echo -e "$msg_senha_invalida"
        # Exibe a lista de requisitos (com emojis de sucesso e erro)
        echo -e "$output"
    fi

    # Retorna 0 se a senha for válida, ou 1 se for inválida
    if [ "$valid" = true ]; then
        return 0
    else
        return 1
    fi
}

# Mensagens do idioma escolhido
#------------------------------
definir_mensagens() {
    case $idioma in
    1)
        # Português
        msg_horario_atual="🕗 Horário atual: \$(date)"
        msg_novo_horario="🕦 Novo horário (após ajuste para \$new_timezone): \$(TZ=\$new_timezone date)"
        msg_ajuste_horario_cancelado="Ajuste do fuso horário cancelado."
        msg_ajuste_horario_resposta_sn="Por favor, responda com 's' para sim ou 'n' para não."
        msg_ajuste_horario_confirmacao="⏱️ Deseja ajustar o fuso horário para \$new_timezone? (s/n): "
        msg_fuso_horario_ajustado="Fuso horário ajustado para \$new_timezone. 🕗 Horário atual: \$(date)"

        msg_configurar="⚙️  Iniciar configurações"
        msg_dominio_solicitar="🌐 Informe o domínio:"
        msg_dominio_informado="✅ Domínio informado:"
        msg_dominio_invalido="❌ Domínio inválido. Por favor, tente novamente."

        # msg_traefik_obter_email="⚙️  Insira o seu e-mail para configurar o Let's Encrypt (certificado ssl) no Traefik:"

        msg_subdominio="🌐 Informe o subdomínio:"

        msg_subdominio_informado="✅ Subdomínio informado:"
        msg_subdominio_invalido="❌ Subdomínio inválido. Por favor, tente novamente."

        msg_senha_solicitar="🔑 Por favor, insira sua senha:"
        msg_senha_ok="✅ Senha informada."

        msg_senha_invalida="⚠️  Senha inválida. A senha precisa preencher todos os requisitos:"
        msg_senha_requisito_min_caracteres="Ter no mínimo 8 caracteres"
        msg_senha_requisito_letra="Conter ao menos uma letra"
        msg_senha_requisito_numero="Conter ao menos 1 número"
        msg_senha_requisito_especial="Conter ao menos 1 caracter especial ! @ # $ % & *"

        msg_email_solicitar="📧 Informe o e-mail:"
        msg_email_informado="✅ Email informado:"
        msg_email_invalido="❌ Email inválido. Tente novamente."

        msg_obter_stack_traefik="⬇️  Baixando Stack Traefik"
        msg_stack_traefik_ok="✅ Stack Traefik baixada e e-mail substituído com sucesso."
        msg_stack_traefik_erro="❌ Erro: Arquivo final da Stack Traefik está vazio ou não foi gerado corretamente."

        msg_obter_stack_portainer="⬇️  Baixando Stack Portainer"
        msg_obter_stack_mysql="⬇️  Baixando Stack MySql"
        msg_obter_stack_pma="⬇️  Baixando Stack phpMyAdmin"
        msg_obter_stack_mautic="⬇️  Baixando Stack Mautic"

        msg_stack_ok="✅ Stack baixada e url substituída com sucesso."
        msg_stack_erro="❌ Erro: Arquivo final da Stack está vazio ou não foi gerado corretamente."

        msg_portainer_definir_senha_admin="⚙️  Definindo a senha do admin no Portainer"
        msg_portainer_definir_senha_admin_ok="✅ Senha do admin definida com sucesso no Portainer."
        msg_portainer_definir_senha_admin_erro="❌ Erro ao definir a senha do admin no Portainer."

        msg_portainer_autenticacao_token="⚙️  Autenticando no Portainer para obter o token JWT"
        msg_portainer_autenticacao_token_ok="✅ Autenticação no Portainer bem-sucedida."
        msg_portainer_autenticacao_token_erro="❌ Erro na autenticação. Verifique o usuário e a senha."

        msg_mysql_verificando="⏳ Verificando se o MySQL está disponível"
        msg_mysql_disponivel="✅ MySQL está disponível!"
        msg_mysql_falha="❌ Falha ao conectar ao MySQL após _RETRIES_ tentativas."
        msg_mysql_verificando_segundos="🔄 Tentativa _ATTEMPT_ de _RETRIES_ para conectar ao MySQL..."

        msg_repository="⚙️  Atualizando Repositórios"
        msg_repository_ok="✅ Repositórios atualizados com sucesso."
        msg_repository_erro="❌ Erro ao atualizar repositórios."

        msg_docker_chave_gpg="⚙️  Verificando Chave GPG do Docker"
        msg_docker_chave_gpg_pular="⚠️  Chave GPG do Docker já existe. Pulando."
        msg_docker_chave_gpg_ok="✅ Chave GPG adicionada com sucesso."
        msg_docker_chave_gpg_erro="❌ Erro ao adicionar chave GPG."

        msg_repositorio_docker="⚙️  Configurando Repositórios do Docker"
        msg_repositorio_docker_pular="⚠️  Repositórios do Docker já configurados. Pulando."
        msg_repositorio_docker_ok="✅ Repositórios do Docker configurados com sucesso."
        msg_repositorio_docker_erro="❌ Erro ao configurar repositórios do Docker."

        msg_instalar_docker="🐋 Instalando Docker"
        msg_instalar_docker_ok="✅ Docker instalado com sucesso."
        msg_instalar_docker_erro="❌ Erro ao instalar o Docker."
        msg_instalar_docker_pular="⚠️  Docker já instalado. Pulando."

        msg_docker_init_auto="🐋 Configurando Docker para iniciar automaticamente"
        msg_docker_init_auto_ok="✅ Serviço Docker configurado para iniciar automaticamente."

        msg_obter_ip="💻 Obtendo IP da máquina"
        msg_obter_ip_erro="❌ Erro ao obter IP da máquina."
        msg_obter_ip_ok="✅ IP da máquina:"

        msg_docker_swarm="🐋 Verificando Docker Swarm"
        msg_docker_swarm_pular="⚠️  Docker Swarm já inicializado. Pulando."
        msg_docker_swarm_ok="✅ Docker Swarm inicializado com sucesso."
        msg_docker_swarm_erro="❌ Erro ao inicializar Docker Swarm."

        msg_docker_network_swarm="🔗 Verificando Rede 'network_swarm_public'"
        msg_docker_network_swarm_pular="⚠️  Rede 'network_swarm_public' já existe. Pulando."
        msg_docker_network_swarm_ok="✅ Rede 'network_swarm_public' criada com sucesso."
        msg_docker_network_swarm_erro="❌ Erro ao criar a rede."

        msg_stack_traefik_deploy="🐋 Subindo Stack Traefik"
        msg_stack_traefik_deploy_ok="✅ Stack Traefik implantada com sucesso!"
        msg_stack_traefik_deploy_erro="❌ Erro ao implantar Stack Traefik."

        msg_stack_portainer_deploy="🐋 Subindo Stack Portainer"
        msg_stack_portainer_deploy_ok="✅ Stack Portainer implantada com sucesso!"
        msg_stack_portainer_deploy_erro="❌ Erro ao implantar Stack Portainer."

        msg_portainer_verificando="⏳ Verificando se o Portainer está disponível"
        msg_portainer_disponivel="✅ O Portainer está ativo."
        msg_portainer_verificando_tentativa="🔄 Tentativa _ATTEMPT_ de _RETRIES_ para conectar ao Portainer..."
        msg_portainer_falha_completa="❌ Falha ao conectar ao Portainer após _RETRIES_ tentativas."

        msg_encerrando_script="❌ Encerrando o script."
        msg_nao_obteve_swarm_id="❌ Não foi possível obter o Swarm ID."
        msg_erro_implantar_stack="❌ Erro ao implantar a stack:"
        msg_stack_implantada_sucesso="implantada com sucesso."
        msg_aguardando="Aguardando: \$i de \$segundos segundos"
        msg_fazendo_deploy_stack="Fazendo deploy da stack"
        msg_resposta_api_portainer="Resposta da API do Portainer:"
        msg_deploy_mautic_cancelado_mysql="❌ O deploy do Mautic foi cancelado porque o MySQL não está disponível."

        msg_script_executado_ok="🚀 Script executado com sucesso!"

        msg_revisao_informacoes="📝 Revise as informações antes de continuar"
        msg_senhas_nao_exibidas="👀 As senhas foram ocultadas por motivos de segurança"
        msg_confirmacao_revisar="👉 As informações estão corretas?"
        msg_prosseguir_enter="🟢 Para confirmar pressione ENTER"
        msg_cancelar_esc="🔴 Para cancelar pressione ESC"
        msg_cancelado_pelo_usuario="💔 Cancelado."

        ;;
    2)
        # English
        msg_horario_atual="🕗 Current time: \$(date)"
        msg_novo_horario="🕦 New time (after adjustment to \$new_timezone): \$(TZ=\$new_timezone date)"
        msg_ajuste_horario_cancelado="Time zone adjustment canceled."
        msg_ajuste_horario_resposta_sn="Please respond with 'y' for yes or 'n' for no."
        msg_ajuste_horario_confirmacao="⏱️ Do you want to adjust the time zone to \$new_timezone? (y/n): "
        msg_fuso_horario_ajustado="Time zone adjusted to \$new_timezone. 🕗 Current time: \$(date)"

        msg_configurar="⚙️  Start configuring"
        msg_dominio_solicitar="🌐 Please enter a domain:"
        msg_dominio_informado="✅ Domain provided:"
        msg_dominio_invalido="❌ Invalid domain. Please try again."

        # msg_traefik_obter_email="⚙️  Enter your email to configure Let's Encrypt (SSL certificate) in Traefik:"

        msg_subdominio="🌐 Please enter the subdomain:"

        msg_subdominio_informado="✅ Subdomain provided:"
        msg_subdominio_invalido="❌ Invalid subdomain. Please try again."

        msg_senha_solicitar="🔑 Please enter your password:"
        msg_senha_ok="✅ Password provided."

        msg_senha_invalida="⚠️  Invalid password. The password must meet all requirements:"
        msg_senha_requisito_min_caracteres="Have at least 8 characters"
        msg_senha_requisito_letra="Contain at least one letter"
        msg_senha_requisito_numero="Contain at least 1 number"
        msg_senha_requisito_especial="Contain at least 1 special character ! @ # $ % & *"

        msg_email_solicitar="📧 Please enter your email:"
        msg_email_informado="✅ Email provided:"
        msg_email_invalido="❌ Invalid email. Please try again."

        msg_obter_stack_traefik="⬇️  Downloading Traefik Stack"
        msg_stack_traefik_ok="✅ Traefik stack downloaded and email successfully replaced."
        msg_stack_traefik_erro="❌ Error: Final Traefik Stack file is empty or was not generated correctly."

        msg_obter_stack_portainer="⬇️  Downloading Portainer Stack"
        msg_obter_stack_mysql="⬇️  Downloading MySQL Stack"
        msg_obter_stack_pma="⬇️  Downloading phpMyAdmin Stack"
        msg_obter_stack_mautic="⬇️  Downloading Mautic Stack"

        msg_stack_ok="✅ Portainer stack downloaded and url successfully replaced."
        msg_stack_erro="❌ Error: Final Portainer Stack file is empty or was not generated correctly."

        msg_portainer_definir_senha_admin="⚙️  Setting the admin password in Portainer"
        msg_portainer_definir_senha_admin_ok="✅ Admin password successfully set in Portainer."
        msg_portainer_definir_senha_admin_erro="❌ Error setting the admin password in Portainer."

        msg_portainer_autenticacao_token="⚙️  Authenticating with Portainer to obtain the JWT token"
        msg_portainer_autenticacao_token_ok="✅ Authentication with Portainer successful."
        msg_portainer_autenticacao_token_erro="❌ Authentication error. Check the username and password."

        msg_mysql_verificando="⏳ Checking if MySQL is available"
        msg_mysql_disponivel="✅ MySQL is available!"
        msg_mysql_falha="❌ Failed to connect to MySQL after _RETRIES_ attempts."
        msg_mysql_verificando_segundos="🔄 Attempt _ATTEMPT_ of _RETRIES_ to connect to MySQL..."

        msg_repository="⚙️  Updating Repositories"
        msg_repository_ok="✅ Repositories successfully updated."
        msg_repository_erro="❌ Error updating repositories."

        msg_docker_chave_gpg="⚙️  Verifying Docker GPG Key"
        msg_docker_chave_gpg_pular="⚠️  Docker GPG key already exists. Skipping."
        msg_docker_chave_gpg_ok="✅ GPG key added successfully."
        msg_docker_chave_gpg_erro="❌ Error adding GPG key."

        msg_repositorio_docker="⚙️  Configuring Docker Repositories"
        msg_repositorio_docker_pular="⚠️  Docker repositories already configured. Skipping."
        msg_repositorio_docker_ok="✅ Docker repositories configured successfully."
        msg_repositorio_docker_erro="❌ Error configuring Docker repositories."

        msg_instalar_docker="🐋 Installing Docker"
        msg_instalar_docker_ok="✅ Docker installed successfully."
        msg_instalar_docker_erro="❌ Error installing Docker."
        msg_instalar_docker_pular="⚠️  Docker already installed. Skipping."

        msg_docker_init_auto="🐋 Configuring Docker to start automatically"
        msg_docker_init_auto_ok="✅ Docker service configured to start automatically."

        msg_obter_ip="💻 Obtaining machine IP"
        msg_obter_ip_erro="❌ Error obtaining machine IP."
        msg_obter_ip_ok="✅ Machine IP:"

        msg_docker_swarm="🐋 Verifying Docker Swarm"
        msg_docker_swarm_pular="⚠️  Docker Swarm already initialized. Skipping."
        msg_docker_swarm_ok="✅ Docker Swarm initialized successfully."
        msg_docker_swarm_erro="❌ Error initializing Docker Swarm."

        msg_docker_network_swarm="🔗 Verifying 'network_swarm_public' Network"
        msg_docker_network_swarm_pular="⚠️  'network_swarm_public' network already exists. Skipping."
        msg_docker_network_swarm_ok="✅ 'network_swarm_public' network created successfully."
        msg_docker_network_swarm_erro="❌ Error creating the network."

        msg_stack_traefik_deploy="🐋 Deploying Traefik Stack"
        msg_stack_traefik_deploy_ok="✅ Traefik Stack deployed successfully!"
        msg_stack_traefik_deploy_erro="❌ Error deploying Traefik Stack."

        msg_stack_portainer_deploy="🐋 Deploying Portainer Stack"
        msg_stack_portainer_deploy_ok="✅ Portainer stack deployed successfully!"
        msg_stack_portainer_deploy_erro="❌ Error deploying Portainer stack."

        msg_portainer_verificando="⏳ Checking if Portainer is available"
        msg_portainer_disponivel="✅ Portainer is active."
        msg_portainer_verificando_tentativa="🔄 Attempt _ATTEMPT_ of _RETRIES_ to connect to Portainer..."
        msg_portainer_falha_completa="❌ Failed to connect to Portainer after _RETRIES_ attempts."

        msg_encerrando_script="❌ Terminating script."
        msg_nao_obteve_swarm_id="❌ Unable to obtain Swarm ID."
        msg_erro_implantar_stack="❌ Error deploying the stack:"
        msg_stack_implantada_sucesso="deployed successfully."
        msg_aguardando="Waiting \$i of \$segundos seconds"
        msg_fazendo_deploy_stack="Deploying the stack"
        msg_resposta_api_portainer="Portainer API response:"
        msg_deploy_mautic_cancelado_mysql="❌ Mautic deployment was canceled because MySQL is unavailable."

        msg_script_executado_ok="🚀 Script executed successfully!"

        msg_revisao_informacoes="📝 Review the information before proceeding"
        msg_senhas_nao_exibidas="👀 Passwords have been hidden for security reasons"
        msg_confirmacao_revisar="👉 Is the information correct?"
        msg_prosseguir_enter="🟢 To confirm, press ENTER"
        msg_cancelar_esc="🔴 To cancel, press ESC"
        msg_cancelado_pelo_usuario="💔 Canceled."

        ;;
    3)
        # Español
        msg_horario_atual="🕗 Hora actual: \$(date)"
        msg_novo_horario="🕦 Nueva hora (tras ajuste a \$new_timezone): \$(TZ=\$new_timezone date)"
        msg_ajuste_horario_cancelado="Ajuste de la zona horaria cancelado."
        msg_ajuste_horario_resposta_sn="Por favor, responda con 's' para sí o 'n' para no."
        msg_ajuste_horario_confirmacao="⏱️ ¿Desea ajustar la zona horaria a \$new_timezone? (s/n): "
        msg_fuso_horario_ajustado="Zona horaria ajustada a \$new_timezone. 🕗 Hora actual: \$(date)"

        msg_configurar="⚙️  Iniciar configuraciones"
        msg_dominio_solicitar="🌐 Por favor, introduzca un dominio:"
        msg_dominio_informado="✅ Dominio informado:"
        msg_dominio_invalido="❌ Dominio inválido. Por favor, intente nuevamente."

        # msg_traefik_obter_email="⚙️  Introduzca su correo electrónico para configurar Let's Encrypt (certificado SSL) en Traefik:"

        msg_subdominio="🌐 Informe el subdominio:"

        msg_subdominio_informado="✅ Subdominio informado:"
        msg_subdominio_invalido="❌ Subdominio inválido. Por favor, intente de nuevo."

        msg_senha_solicitar="🔑 Por favor, introduzca su contraseña:"
        msg_senha_ok="✅ Contraseña proporcionada."

        msg_senha_invalida="⚠️  Contraseña inválida. La contraseña debe cumplir todos los requisitos:"
        msg_senha_requisito_min_caracteres="Tener al menos 8 caracteres"
        msg_senha_requisito_letra="Contener al menos una letra"
        msg_senha_requisito_numero="Contener al menos 1 número"
        msg_senha_requisito_especial="Contener al menos 1 carácter especial ! @ # $ % & *"

        msg_email_solicitar="📧 Informe su correo electrónico:"
        msg_email_informado="✅ Correo electrónico informado:"
        msg_email_invalido="❌ Correo electrónico inválido. Intente nuevamente."

        msg_obter_stack_traefik="⬇️  Descargando la Stack de Traefik"
        msg_stack_traefik_ok="✅ Stack de Traefik descargada y correo electrónico reemplazado con éxito."
        msg_stack_traefik_erro="❌ Error: El archivo final de la Stack de Traefik está vacío o no se generó correctamente."

        msg_obter_stack_portainer="⬇️  Descargando la Stack de Portainer"
        msg_obter_stack_mysql="⬇️  Descargando Stack de MySQL"
        msg_obter_stack_pma="⬇️  Descargando Stack de phpMyAdmin"
        msg_obter_stack_mautic="⬇️  Descargando Stack de Mautic"

        msg_stack_ok="✅ Stack de Portainer descargada y url reemplazado con éxito."
        msg_stack_erro="❌ Error: El archivo final de la Stack de Portainer está vacío o no se generó correctamente."

        msg_portainer_definir_senha_admin="⚙️  Configurando la contraseña de administrador en Portainer"
        msg_portainer_definir_senha_admin_ok="✅ Contraseña de administrador configurada con éxito en Portainer."
        msg_portainer_definir_senha_admin_erro="❌ Error al configurar la contraseña de administrador en Portainer."

        msg_portainer_autenticacao_token="⚙️  Autenticando en Portainer para obtener el token JWT"
        msg_portainer_autenticacao_token_ok="✅ Autenticación en Portainer exitosa."
        msg_portainer_autenticacao_token_erro="❌ Error de autenticación. Verifique el nombre de usuario y la contraseña."

        msg_mysql_verificando="⏳ Verificando si MySQL está disponible"
        msg_mysql_disponivel="✅ MySQL está disponible!"
        msg_mysql_falha="❌ Falló al conectar a MySQL después de _RETRIES_ intentos."
        msg_mysql_verificando_segundos="🔄 Intento _ATTEMPT_ de _RETRIES_ para conectar a MySQL..."

        msg_repository="⚙️  Actualizando Repositorios"
        msg_repository_ok="✅ Repositorios actualizados con éxito."
        msg_repository_erro="❌ Error al actualizar los repositorios."

        msg_docker_chave_gpg="⚙️  Verificando la Clave GPG de Docker"
        msg_docker_chave_gpg_pular="⚠️  La clave GPG de Docker ya existe. Saltando."
        msg_docker_chave_gpg_ok="✅ Clave GPG añadida con éxito."
        msg_docker_chave_gpg_erro="❌ Error al añadir la clave GPG."

        msg_repositorio_docker="⚙️  Configurando Repositorios de Docker"
        msg_repositorio_docker_pular="⚠️  Los repositorios de Docker ya están configurados. Saltando."
        msg_repositorio_docker_ok="✅ Repositorios de Docker configurados con éxito."
        msg_repositorio_docker_erro="❌ Error al configurar los repositorios de Docker."

        msg_instalar_docker="🐋 Instalando Docker"
        msg_instalar_docker_ok="✅ Docker instalado con éxito."
        msg_instalar_docker_erro="❌ Error al instalar Docker."
        msg_instalar_docker_pular="⚠️  Docker ya está instalado. Saltando."

        msg_docker_init_auto="🐋 Configurando Docker para iniciar automáticamente"
        msg_docker_init_auto_ok="✅ Servicio Docker configurado para iniciar automáticamente."

        msg_obter_ip="💻 Obteniendo IP de la máquina"
        msg_obter_ip_erro="❌ Error al obtener la IP de la máquina."
        msg_obter_ip_ok="✅ IP de la máquina:"

        msg_docker_swarm="🐋 Verificando Docker Swarm"
        msg_docker_swarm_pular="⚠️  Docker Swarm ya está inicializado. Saltando."
        msg_docker_swarm_ok="✅ Docker Swarm inicializado con éxito."
        msg_docker_swarm_erro="❌ Error al inicializar Docker Swarm."

        msg_docker_network_swarm="🔗 Verificando la Red 'network_swarm_public'"
        msg_docker_network_swarm_pular="⚠️  La red 'network_swarm_public' ya existe. Saltando."
        msg_docker_network_swarm_ok="✅ Red 'network_swarm_public' creada con éxito."
        msg_docker_network_swarm_erro="❌ Error al crear la red."

        msg_stack_traefik_deploy="🐋 Desplegando la Stack de Traefik"
        msg_stack_traefik_deploy_ok="✅ Stack de Traefik desplegada con éxito!"
        msg_stack_traefik_deploy_erro="❌ Error al desplegar la Stack de Traefik."

        msg_stack_portainer_deploy="🐋 Desplegando Stack Portainer"
        msg_stack_portainer_deploy_ok="✅ Stack Portainer desplegada con éxito!"
        msg_stack_portainer_deploy_erro="❌ Error al desplegar Stack Portainer."

        msg_portainer_verificando="⏳ Verificando si Portainer está disponible"
        msg_portainer_disponivel="✅ Portainer está activo."
        msg_portainer_verificando_tentativa="🔄 Intento _ATTEMPT_ de _RETRIES_ para conectar a Portainer..."
        msg_portainer_falha_completa="❌ Error al conectar con Portainer después de _RETRIES_ intentos."

        msg_encerrando_script="❌ Cerrando el script."
        msg_nao_obteve_swarm_id="❌ No se pudo obtener el ID de Swarm."
        msg_erro_implantar_stack="❌ Error al desplegar la stack:"
        msg_stack_implantada_sucesso="desplegada con éxito."
        msg_aguardando="Aguardando \$i de \$segundos segundos"
        msg_fazendo_deploy_stack="Desplegando la stack"
        msg_resposta_api_portainer="Respuesta de la API de Portainer:"
        msg_deploy_mautic_cancelado_mysql="❌ El despliegue de Mautic fue cancelado porque MySQL no está disponible."

        msg_script_executado_ok="🚀 ¡Script ejecutado con éxito!"

        msg_revisao_informacoes="📝 Revise la información antes de continuar"
        msg_senhas_nao_exibidas="👀 Las contraseñas han sido ocultadas por razones de seguridad"
        msg_confirmacao_revisar="👉 ¿La información es correcta?"
        msg_prosseguir_enter="🟢 Para confirmar, presione ENTER"
        msg_cancelar_esc="🔴 Para cancelar, presione ESC"
        msg_cancelado_pelo_usuario="💔 Cancelado."

        ;;
    4)
        # Français
        msg_horario_atual="🕗 Heure actuelle : \$(date)"
        msg_novo_horario="🕦 Nouvelle heure (après ajustement pour \$new_timezone) : \$(TZ=\$new_timezone date)"
        msg_ajuste_horario_cancelado="Ajustement du fuseau horaire annulé."
        msg_ajuste_horario_resposta_sn="Veuillez répondre par 'o' pour oui ou 'n' pour non."
        msg_ajuste_horario_confirmacao="⏱️ Voulez-vous ajuster le fuseau horaire à \$new_timezone ? (o/n): "
        msg_fuso_horario_ajustado="Fuseau horaire ajusté à \$new_timezone. 🕗 Heure actuelle : \$(date)"

        msg_configurar="⚙️  Commencer les configurations"
        msg_dominio_solicitar="🌐 Veuillez saisir un domaine :"
        msg_dominio_informado="✅ Domaine fourni :"
        msg_dominio_invalido="❌ Domaine invalide. Veuillez réessayer."

        # msg_traefik_obter_email="⚙️  Veuillez saisir votre e-mail pour configurer Let's Encrypt (certificat SSL) sur Traefik :"

        msg_subdominio="🌐 Veuillez entrer le sous-domaine :"

        msg_subdominio_informado="✅ Sous-domaine fourni :"
        msg_subdominio_invalido="❌ Sous-domaine invalide. Veuillez réessayer."

        msg_senha_solicitar="🔑 Veuillez saisir votre mot de passe :"
        msg_senha_ok="✅ Mot de passe fourni."

        msg_senha_invalida="⚠️  Mot de passe invalide. Le mot de passe doit remplir toutes les conditions :"
        msg_senha_requisito_min_caracteres="Avoir au moins 8 caractères"
        msg_senha_requisito_letra="Contenir au moins une lettre"
        msg_senha_requisito_numero="Contenir au moins 1 chiffre"
        msg_senha_requisito_especial="Contenir au moins 1 caractère spécial ! @ # $ % & *"

        msg_email_solicitar="📧 Veuillez entrer votre e-mail :"
        msg_email_informado="✅ E-mail fourni :"
        msg_email_invalido="❌ E-mail invalide. Veuillez réessayer."

        msg_obter_stack_traefik="⬇️  Téléchargement de la Stack Traefik"
        msg_stack_traefik_ok="✅ Stack Traefik téléchargée et e-mail remplacé avec succès."
        msg_stack_traefik_erro="❌ Erreur : Le fichier final de la Stack Traefik est vide ou n'a pas été généré correctement."

        msg_obter_stack_portainer="⬇️  Téléchargement de la Stack Portainer"
        msg_obter_stack_mysql="⬇️  Téléchargement de la Stack MySQL"
        msg_obter_stack_pma="⬇️  Téléchargement de la Stack phpMyAdmin"
        msg_obter_stack_mautic="⬇️  Téléchargement de la Stack Mautic"

        msg_stack_ok="✅ Stack Portainer téléchargée et url remplacé avec succès."
        msg_stack_erro="❌ Erreur : Le fichier final de la Stack Portainer est vide ou n'a pas été généré correctement."

        msg_portainer_definir_senha_admin="⚙️  Définition du mot de passe administrateur dans Portainer"
        msg_portainer_definir_senha_admin_ok="✅ Mot de passe administrateur défini avec succès dans Portainer."
        msg_portainer_definir_senha_admin_erro="❌ Erreur lors de la définition du mot de passe administrateur dans Portainer."

        msg_portainer_autenticacao_token="⚙️  Authentification avec Portainer pour obtenir le jeton JWT"
        msg_portainer_autenticacao_token_ok="✅ Authentification réussie avec Portainer."
        msg_portainer_autenticacao_token_erro="❌ Erreur d'authentification. Vérifiez le nom d'utilisateur et le mot de passe."

        msg_mysql_verificando="⏳ Vérification de la disponibilité de MySQL"
        msg_mysql_disponivel="✅ MySQL est disponible !"
        msg_mysql_falha="❌ Échec de la connexion à MySQL après _RETRIES_ tentatives."
        msg_mysql_verificando_segundos="🔄 Tentative _ATTEMPT_ sur _RETRIES_ pour se connecter à MySQL..."

        msg_repository="⚙️  Mise à jour des dépôts"
        msg_repository_ok="✅ Dépôts mis à jour avec succès."
        msg_repository_erro="❌ Erreur lors de la mise à jour des dépôts."

        msg_docker_chave_gpg="⚙️  Vérification de la clé GPG de Docker"
        msg_docker_chave_gpg_pular="⚠️  La clé GPG de Docker existe déjà. Ignorer."
        msg_docker_chave_gpg_ok="✅ Clé GPG ajoutée avec succès."
        msg_docker_chave_gpg_erro="❌ Erreur lors de l'ajout de la clé GPG."

        msg_repositorio_docker="⚙️  Configuration des dépôts Docker"
        msg_repositorio_docker_pular="⚠️  Les dépôts Docker sont déjà configurés. Ignorer."
        msg_repositorio_docker_ok="✅ Dépôts Docker configurés avec succès."
        msg_repositorio_docker_erro="❌ Erreur lors de la configuration des dépôts Docker."

        msg_instalar_docker="🐋 Installation de Docker"
        msg_instalar_docker_ok="✅ Docker installé avec succès."
        msg_instalar_docker_erro="❌ Erreur lors de l'installation de Docker."
        msg_instalar_docker_pular="⚠️  Docker est déjà installé. Ignorer."

        msg_docker_init_auto="🐋 Configuration de Docker pour démarrer automatiquement"
        msg_docker_init_auto_ok="✅ Service Docker configuré pour démarrer automatiquement."

        msg_obter_ip="💻 Obtention de l'IP de la machine"
        msg_obter_ip_erro="❌ Erreur lors de l'obtention de l'IP de la machine."
        msg_obter_ip_ok="✅ IP de la machine :"

        msg_docker_swarm="🐋 Vérification de Docker Swarm"
        msg_docker_swarm_pular="⚠️  Docker Swarm est déjà initialisé. Ignorer."
        msg_docker_swarm_ok="✅ Docker Swarm initialisé avec succès."
        msg_docker_swarm_erro="❌ Erreur lors de l'initialisation de Docker Swarm."

        msg_docker_network_swarm="🔗 Vérification du Réseau 'network_swarm_public'"
        msg_docker_network_swarm_pular="⚠️  Le réseau 'network_swarm_public' existe déjà. Ignorer."
        msg_docker_network_swarm_ok="✅ Réseau 'network_swarm_public' créé avec succès."
        msg_docker_network_swarm_erro="❌ Erreur lors de la création du réseau."

        msg_stack_traefik_deploy="🐋 Déploiement de la Stack Traefik"
        msg_stack_traefik_deploy_ok="✅ Stack Traefik déployée avec succès !"
        msg_stack_traefik_deploy_erro="❌ Erreur lors du déploiement de la Stack Traefik."

        msg_stack_portainer_deploy="🐋 Déploiement de la Stack Portainer"
        msg_stack_portainer_deploy_ok="✅ Stack Portainer déployée avec succès !"
        msg_stack_portainer_deploy_erro="❌ Erreur lors du déploiement de la Stack Portainer."

        msg_portainer_verificando="⏳ Vérification si Portainer est disponible"
        msg_portainer_disponivel="✅ Portainer est actif."
        msg_portainer_verificando_tentativa="🔄 Tentative _ATTEMPT_ de _RETRIES_ pour se connecter à Portainer..."
        msg_portainer_falha_completa="❌ Échec de la connexion à Portainer après _RETRIES_ tentatives."

        msg_encerrando_script="❌ Fermeture du script."
        msg_nao_obteve_swarm_id="❌ Impossible d'obtenir l'ID Swarm."
        msg_erro_implantar_stack="❌ Erreur lors du déploiement de la stack :"
        msg_stack_implantada_sucesso="déployée avec succès."
        msg_aguardando="Attendre \$i seconde sur \$segundos"
        msg_fazendo_deploy_stack="Déploiement de la stack"
        msg_resposta_api_portainer="Réponse de l'API Portainer :"
        msg_deploy_mautic_cancelado_mysql="❌ Le déploiement de Mautic a été annulé car MySQL n'est pas disponible."

        msg_script_executado_ok="🚀 Script exécuté avec succès !"

        msg_revisao_informacoes="📝 Vérifiez les informations avant de continuer"
        msg_senhas_nao_exibidas="👀 Les mots de passe ont été masqués pour des raisons de sécurité"
        msg_confirmacao_revisar="👉 Les informations sont-elles correctes ?"
        msg_prosseguir_enter="🟢 Pour confirmer, appuyez sur ENTER"
        msg_cancelar_esc="🔴 Pour annuler, appuyez sur ESC"
        msg_cancelado_pelo_usuario="💔 Annulé."

        ;;
    5)
        # Italiano
        msg_horario_atual="🕗 Ora attuale: \$(date)"
        msg_novo_horario="🕦 Nuovo orario (dopo l'adeguamento a \$new_timezone): \$(TZ=\$new_timezone date)"
        msg_ajuste_horario_cancelado="Regolazione del fuso orario annullata."
        msg_ajuste_horario_resposta_sn="Rispondi con 's' per sì o 'n' per no."
        msg_ajuste_horario_confirmacao="⏱️ Vuoi regolare il fuso orario a \$new_timezone? (s/n): "
        msg_fuso_horario_ajustado="Fuso orario regolato a \$new_timezone. 🕗 Ora attuale: \$(date)"

        msg_configurar="⚙️  Iniziare le configurazioni"
        msg_dominio_solicitar="🌐 Per favore, inserisci un dominio:"
        msg_dominio_informado="✅ Dominio fornito:"
        msg_dominio_invalido="❌ Dominio non valido. Per favore, riprova."

        # msg_traefik_obter_email="⚙️  Inserisci la tua email per configurare Let's Encrypt (certificato SSL) su Traefik:"

        msg_subdominio="🌐 Inserisci il sottodominio"

        msg_subdominio_informado="✅ Sottodominio fornito:"
        msg_subdominio_invalido="❌ Sottodominio non valido. Per favore, riprova."

        msg_senha_solicitar="🔑 Per favore, inserisci la tua password:"
        msg_senha_ok="✅ Password fornita."

        msg_senha_invalida="⚠️  Password non valida. La password deve soddisfare tutti i requisiti:"
        msg_senha_requisito_min_caracteres="Avere almeno 8 caratteri"
        msg_senha_requisito_letra="Contenere almeno una lettera"
        msg_senha_requisito_numero="Contenere almeno 1 numero"
        msg_senha_requisito_especial="Contenere almeno 1 carattere speciale ! @ # $ % & *"

        msg_email_solicitar="📧 Inserisci la tua email:"
        msg_email_informado="✅ Email fornito:"
        msg_email_invalido="❌ Email non valida. Riprova."

        msg_obter_stack_traefik="⬇️  Scaricamento della Stack Traefik"
        msg_stack_traefik_ok="✅ Stack Traefik scaricata e email sostituita con successo."
        msg_stack_traefik_erro="❌ Errore: Il file finale della Stack Traefik è vuoto o non è stato generato correttamente."

        msg_obter_stack_portainer="⬇️  Scaricamento della Stack Portainer"
        msg_obter_stack_mysql="⬇️  Scaricamento Stack MySQL"
        msg_obter_stack_pma="⬇️  Scaricamento Stack phpMyAdmin"
        msg_obter_stack_mautic="⬇️  Scaricamento Stack Mautic"

        msg_stack_ok="✅ Stack Portainer scaricata e url sostituita con successo."
        msg_stack_erro="❌ Errore: Il file finale della Stack Portainer è vuoto o non è stato generato correttamente."

        msg_portainer_definir_senha_admin="⚙️  Impostazione della password amministratore in Portainer"
        msg_portainer_definir_senha_admin_ok="✅ Password amministratore impostata con successo in Portainer."
        msg_portainer_definir_senha_admin_erro="❌ Errore durante l'impostazione della password amministratore in Portainer."

        msg_portainer_autenticacao_token="⚙️  Autenticazione su Portainer per ottenere il token JWT"
        msg_portainer_autenticacao_token_ok="✅ Autenticazione su Portainer riuscita."
        msg_portainer_autenticacao_token_erro="❌ Errore di autenticazione. Verifica nome utente e password."

        msg_mysql_verificando="⏳ Verificando se MySQL è disponibile"
        msg_mysql_disponivel="✅ MySQL è disponibile!"
        msg_mysql_falha="❌ Impossibile connettersi a MySQL dopo _RETRIES_ tentativi."
        msg_mysql_verificando_segundos="🔄 Tentativo _ATTEMPT_ di _RETRIES_ per connettersi a MySQL..."

        msg_repository="⚙️  Aggiornamento dei repository"
        msg_repository_ok="✅ Repository aggiornati con successo."
        msg_repository_erro="❌ Errore durante l'aggiornamento dei repository."

        msg_docker_chave_gpg="⚙️  Verifica della chiave GPG di Docker"
        msg_docker_chave_gpg_pular="⚠️  La chiave GPG di Docker esiste già. Saltando."
        msg_docker_chave_gpg_ok="✅ Chiave GPG aggiunta con successo."
        msg_docker_chave_gpg_erro="❌ Errore nell'aggiunta della chiave GPG."

        msg_repositorio_docker="⚙️  Configurazione dei repository di Docker"
        msg_repositorio_docker_pular="⚠️  I repository di Docker sono già configurati. Saltando."
        msg_repositorio_docker_ok="✅ Repository di Docker configurati con successo."
        msg_repositorio_docker_erro="❌ Errore nella configurazione dei repository di Docker."

        msg_instalar_docker="🐋 Installazione di Docker"
        msg_instalar_docker_ok="✅ Docker installato con successo."
        msg_instalar_docker_erro="❌ Errore durante l'installazione di Docker."
        msg_instalar_docker_pular="⚠️  Docker è già installato. Saltando."

        msg_docker_init_auto="🐋 Configurazione di Docker per avviarsi automaticamente"
        msg_docker_init_auto_ok="✅ Servizio Docker configurato per avviarsi automaticamente."

        msg_obter_ip="💻 Ottenimento dell'IP della macchina"
        msg_obter_ip_erro="❌ Errore durante l'ottenimento dell'IP della macchina."
        msg_obter_ip_ok="✅ IP della macchina:"

        msg_docker_swarm="🐋 Verifica di Docker Swarm"
        msg_docker_swarm_pular="⚠️  Docker Swarm è già inizializzato. Saltando."
        msg_docker_swarm_ok="✅ Docker Swarm inizializzato con successo."
        msg_docker_swarm_erro="❌ Errore durante l'inizializzazione di Docker Swarm."

        msg_docker_network_swarm="🔗 Verifica della rete 'network_swarm_public'"
        msg_docker_network_swarm_pular="⚠️  La rete 'network_swarm_public' esiste già. Saltando."
        msg_docker_network_swarm_ok="✅ Rete 'network_swarm_public' creata con successo."
        msg_docker_network_swarm_erro="❌ Errore nella creazione della rete."

        msg_stack_traefik_deploy="🐋 Avvio della Stack Traefik"
        msg_stack_traefik_deploy_ok="✅ Stack Traefik avviata con successo!"
        msg_stack_traefik_deploy_erro="❌ Errore nell'avvio della Stack Traefik."

        msg_stack_portainer_deploy="🐋 Esecuzione della Stack Portainer"
        msg_stack_portainer_deploy_ok="✅ Stack Portainer eseguita con successo!"
        msg_stack_portainer_deploy_erro="❌ Errore durante l'esecuzione della Stack Portainer."

        msg_portainer_verificando="⏳ Verificando se Portainer è disponibile"
        msg_portainer_disponivel="✅ Portainer è attivo."
        msg_portainer_verificando_tentativa="🔄 Tentativo _ATTEMPT_ di _RETRIES_ per connettersi a Portainer..."
        msg_portainer_falha_completa="❌ Impossibile connettersi a Portainer dopo _RETRIES_ tentativi."

        msg_encerrando_script="❌ Chiusura dello script."
        msg_nao_obteve_swarm_id="❌ Impossibile ottenere l'ID Swarm."
        msg_erro_implantar_stack="❌ Errore durante il deploy della stack:"
        msg_stack_implantada_sucesso="distribuita con successo."
        msg_aguardando="In attesa di \$i secondo su \$segundos"
        msg_fazendo_deploy_stack="Distribuzione della stack"
        msg_resposta_api_portainer="Risposta dell'API Portainer:"
        msg_deploy_mautic_cancelado_mysql="❌ Il deploy di Mautic è stato annullato perché MySQL non è disponibile."

        msg_script_executado_ok="🚀 Script eseguito con successo!"

        msg_revisao_informacoes="📝 Rivedi le informazioni prima di continuare"
        msg_senhas_nao_exibidas="👀 Le password sono state nascoste per motivi di sicurezza"
        msg_confirmacao_revisar="👉 Le informazioni sono corrette?"
        msg_prosseguir_enter="🟢 Per confermare, premi ENTER"
        msg_cancelar_esc="🔴 Per annullare, premi ESC"
        msg_cancelado_pelo_usuario="💔 Annullato."

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

# Escolha do idioma
#------------------
while true; do
    menu_idioma
    if definir_mensagens; then
        echo ""
        ajustar_fuso_horario $idioma
        echo ""
        break
    fi
done

# Iniciar configurações
#----------------------
print_with_line "$msg_configurar" "yellow;bold;default"
echo ""

# Domínio
#--------
while true; do
    read -e -p "$msg_dominio_solicitar " DOMINIO

    if validar_dominio "$DOMINIO"; then
        break
    else
        echo -e "$msg_dominio_invalido"
        echo ""
    fi
done
echo ""

format_multi_part_text "[;yellow;default;default" "Traefik;white;default;default" "]\n;yellow;default;default"
# E-mail do traefik
#------------------
while true; do
    read -e -p "$msg_email_solicitar " CHANGE_EMAIL_TRAEFIK

    if validar_email "$CHANGE_EMAIL_TRAEFIK"; then
        break
    else
        echo "$msg_email_invalido"
        echo ""
    fi
done
echo ""

format_multi_part_text "[;yellow;default;default" "Portainer;white;default;default" "]\n;yellow;default;default"
# Subdominio do Portainer
#------------------------------------
while true; do
    read -e -p "$msg_subdominio " -i "$SUBDOMINIO_PORTAINER_DEFAULT" SUBDOMINIO_PORTAINER # Exibe o valor padrão e permite edição

    if validar_subdominio "$SUBDOMINIO_PORTAINER"; then
        break
    else
        echo -e "$msg_subdominio_invalido"
        echo ""
    fi
done

# Senha do Admin do Portainer
#----------------------------------------
while true; do
    if [ "$MODE" == "DEBUG" ]; then
        # exibe a senha
        read -e -p "$msg_senha_solicitar " CHANGE_PORTAINER_ADMIN_PASSWORD
    else
        read -e -s -p "$msg_senha_solicitar " CHANGE_PORTAINER_ADMIN_PASSWORD
    fi
    if validar_senha "$CHANGE_PORTAINER_ADMIN_PASSWORD"; then
        break
    fi
done
echo ""

format_multi_part_text "[;yellow;default;default" "MySql;white;default;default" "]\n;yellow;default;default"
# Senha do Admin do MySql
#------------------------
while true; do
    if [ "$MODE" == "DEBUG" ]; then
        # exibe a senha
        read -e -p "$msg_senha_solicitar " CHANGE_MYSQL_ROOT_PASSWORD
    else
        read -e -s -p "$msg_senha_solicitar " CHANGE_MYSQL_ROOT_PASSWORD
    fi
    if validar_senha "$CHANGE_MYSQL_ROOT_PASSWORD"; then
        break
    fi
done
echo ""

format_multi_part_text "[;yellow;default;default" "phpMyAdmin;white;default;default" "]\n;yellow;default;default"
# Subdomínio para o phpMyAdmin
#-----------------------------
while true; do
    read -e -p "$msg_subdominio " -i "$SUBDOMINIO_PMA_DEFAULT" SUBDOMINIO_PMA
    if validar_subdominio "$SUBDOMINIO_PMA"; then
        break
    else
        echo -e "$msg_subdominio_invalido"
        echo ""
    fi
done
echo ""

format_multi_part_text "[;yellow;default;default" "Mautic;white;default;default" "]\n;yellow;default;default"
# Subdomínio para o Mautic
#-------------------------
while true; do
    read -e -p "$msg_subdominio " -i "$SUBDOMINIO_MAUTIC_DEFAULT" SUBDOMINIO_MAUTIC
    if validar_subdominio "$SUBDOMINIO_MAUTIC"; then
        break
    else
        echo -e "$msg_subdominio_invalido"
        echo ""
    fi
done

# E-mail do Admin do Mautic
#--------------------------
while true; do
    read -e -p "$msg_email_solicitar " -i "$CHANGE_EMAIL_TRAEFIK" CHANGE_MAUTIC_ADMIN_EMAIL
    if validar_email "$CHANGE_MAUTIC_ADMIN_EMAIL"; then
        break
    else
        echo -e "$msg_email_invalido"
        echo ""
    fi
done

# Senha do Admin do Mautic
#-------------------------
while true; do
    # Exibe a senha do MySql e permite edição
    if [ "$MODE" == "DEBUG" ]; then
        # exibe a senha
        read -e -p "$msg_senha_solicitar " CHANGE_MAUTIC_ADMIN_PASSWORD
    else
        read -e -s -p "$msg_senha_solicitar " CHANGE_MAUTIC_ADMIN_PASSWORD
    fi
    if validar_senha "$CHANGE_MAUTIC_ADMIN_PASSWORD"; then
        break
    fi
done
echo ""

########################################
# Revisar entradas antes de prosseguir #
########################################
echo ""
print_with_line "$msg_revisao_informacoes" "yellow;bold;default"
echo ""

# dominio
format_multi_part_text "$msg_dominio_informado;yellow;default;default" " $DOMINIO\n;white;default;default"
echo ""

# Traefik
format_multi_part_text "[;yellow;default;default" "Traefik;white;default;default" "]\n;yellow;default;default"
format_multi_part_text "$msg_email_informado;yellow;default;default" " $CHANGE_EMAIL_TRAEFIK\n;white;default;default"
echo ""

# Portainer
format_multi_part_text "[;yellow;default;default" "Portainer;white;default;default" "]\n;yellow;default;default"
format_multi_part_text "$msg_subdominio_informado;yellow;default;default" " $SUBDOMINIO_PORTAINER.$DOMINIO\n;white;default;default"
debug_log "${msg_senha_ok/./:};yellow;default;default"
debug_log " $CHANGE_PORTAINER_ADMIN_PASSWORD\n;white;default;default"
echo ""

# MySql - exibe a senha se está no modo DEBUG
debug_log "[;yellow;default;default"
debug_log "MySql;white;default;default"
debug_log "]\n;yellow;default;default"
debug_log "${msg_senha_ok/./:};yellow;default;default"
debug_log " $CHANGE_MYSQL_ROOT_PASSWORD\n\n;white;default;default"

# phpMyAdmin
format_multi_part_text "[;yellow;default;default" "phpMyAdmin;white;default;default" "]\n;yellow;default;default"
format_multi_part_text "$msg_subdominio_informado;yellow;default;default" " $SUBDOMINIO_PMA.$DOMINIO\n;white;default;default"
echo ""

# Mautic
format_multi_part_text "[;yellow;default;default" "Mautic;white;default;default" "]\n;yellow;default;default"
format_multi_part_text "$msg_subdominio_informado;yellow;default;default" " $SUBDOMINIO_MAUTIC.$DOMINIO\n;white;default;default"
format_multi_part_text "$msg_email_informado;yellow;default;default" " $CHANGE_MAUTIC_ADMIN_EMAIL\n;white;default;default"
debug_log "${msg_senha_ok/./:};yellow;default;default"
debug_log " $CHANGE_MAUTIC_ADMIN_PASSWORD\n;white;default;default"
if [ "$MODE" != "DEBUG" ]; then
    # Não exibir as senhas
    echo ""
    format_multi_part_text "$msg_senhas_nao_exibidas\n;purple;italic;default"
fi
echo ""
echo ""
format_multi_part_text "$msg_confirmacao_revisar\n;yellow;underline;default"
echo ""
format_multi_part_text "$msg_prosseguir_enter\n;cyan;default;default"
format_multi_part_text "$msg_cancelar_esc\n;red;italic;default"

# Aguardar confirmação
while true; do
    read -rsn1 input
    if [[ "$input" == "" ]]; then
        # Usuário pressionou ENTER, continuar com a execução
        break
    elif [[ "$input" == $'\e' ]]; then
        # Usuário pressionou ESC, encerrar o script
        echo ""
        format_multi_part_text "$msg_cancelado_pelo_usuario\n;red;bold;default"
        echo ""
        exit 0
    fi
done
echo ""

########################
# Baixar stack Traefik #
########################
echo ""
print_with_line "$msg_obter_stack_traefik" "yellow;bold;default"
echo ""

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-traefik-v2.yml | sed "s/CHANGE_EMAIL_TRAEFIK/${CHANGE_EMAIL_TRAEFIK}/g" >stack-traefik-v2.yml

if [[ -s stack-traefik-v2.yml ]]; then
    echo -e "$msg_stack_traefik_ok"
else
    format_multi_part_text "$msg_stack_traefik_erro\n;red;bold;default"
    exit 1
fi
echo ""

##########################
# Baixar stack Portainer #
##########################
echo ""
print_with_line "$msg_obter_stack_portainer" "yellow;bold;default"
echo ""

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-portainer.yml | sed "s/CHANGE_URL_PORTAINER/${SUBDOMINIO_PORTAINER}.${DOMINIO}/g" >stack-portainer.yml

if [[ -s stack-portainer.yml ]]; then
    echo -e "$msg_stack_ok"
else
    format_multi_part_text "$msg_stack_erro\n;red;bold;default"
    exit 1
fi
echo ""

######################
# Baixar stack MySql #
######################
echo ""
print_with_line "$msg_obter_stack_mysql" "yellow;bold;default"
echo ""

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-mysql-mautic.yml | sed "s/CHANGE_MYSQL_ROOT_PASSWORD/${CHANGE_MYSQL_ROOT_PASSWORD}/g" >stack-mysql-mautic.yml

if [[ -s stack-mysql-mautic.yml ]]; then
    echo -e "$msg_stack_ok"
else
    format_multi_part_text "$msg_stack_erro\n;red;bold;default"
    exit 1
fi
echo ""

###########################
# Baixar stack phpMyAdmin #
###########################
echo ""
print_with_line "$msg_obter_stack_pma" "yellow;bold;default"
echo ""

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-pma.yml | sed "s/CHANGE_URL_PMA/${SUBDOMINIO_PMA}.${DOMINIO}/g" >stack-pma.yml

if [[ -s stack-pma.yml ]]; then
    echo -e "$msg_stack_ok"
else
    format_multi_part_text "$msg_stack_erro\n;red;bold;default"
    exit 1
fi
echo ""

#######################
# Baixar stack Mautic #
#######################
echo ""
print_with_line "$msg_obter_stack_mautic" "yellow;bold;default"
echo ""

curl -s https://raw.githubusercontent.com/marioguima/email-marketing-lucrativo/main/stack-mautic.yml |
    sed -e "s/CHANGE_URL_MAUTIC/${SUBDOMINIO_MAUTIC}.${DOMINIO}/g" \
        -e "s/CHANGE_MYSQL_ROOT_PASSWORD/${CHANGE_MYSQL_ROOT_PASSWORD}/g" \
        -e "s/CHANGE_MAUTIC_ADMIN_EMAIL/${CHANGE_MAUTIC_ADMIN_EMAIL}/g" \
        -e "s/CHANGE_MAUTIC_ADMIN_PASSWORD/${CHANGE_MAUTIC_ADMIN_PASSWORD}/g" >stack-mautic.yml

if [[ -s stack-mautic.yml ]]; then
    echo -e "$msg_stack_ok"
else
    format_multi_part_text "$msg_stack_erro\n;red;bold;default"
    exit 1
fi
echo ""

#######################
# Update repositórios #
#######################
echo ""
print_with_line "$msg_repository" "yellow;bold;default"
echo ""

apt-get update && apt install -y sudo gnupg2 wget ca-certificates apt-transport-https curl gnupg nano htop default-mysql-client jq

echo ""
if [ $? -eq 0 ]; then
    echo -e "$msg_repository_ok"
else
    format_multi_part_text "$msg_repository_erro\n;red;bold;default"
    exit 1
fi
echo ""

#################################
# Verificar chave GPG do Docker #
#################################
echo ""
print_with_line "$msg_docker_chave_gpg" "yellow;bold;default"
echo ""

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    if [ $? -eq 0 ]; then
        echo -e "$msg_docker_chave_gpg_ok"
    else
        echo -e "$msg_docker_chave_gpg_erro"
        exit 1
    fi
else
    format_multi_part_text "$msg_docker_chave_gpg_pular\n;yellow;italic;default"
fi
echo ""

#######################################
# Configurando Repositórios do Docker #
#######################################
echo ""
print_with_line "$msg_repositorio_docker" "yellow;bold;default"
echo ""

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    echo ""
    if [ $? -eq 0 ]; then
        echo -e "$msg_repositorio_docker_ok"
    else
        format_multi_part_text "$msg_repositorio_docker_erro\n;red;bold;default"
        exit 1
    fi
else
    format_multi_part_text "$msg_repositorio_docker_pular\n;yellow;italic;default"
fi
echo ""

###################
# Instalar Docker #
###################
echo ""
print_with_line "$msg_instalar_docker" "yellow;bold;default"
echo ""

if ! command -v docker &>/dev/null; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo ""
    if [ $? -eq 0 ]; then
        echo -e "$msg_instalar_docker_ok"
    else
        format_multi_part_text "$msg_instalar_docker_erro\n;red;bold;default"
        exit 1
    fi
else
    format_multi_part_text "$msg_instalar_docker_pular\n;yellow;italic;default"
fi
echo ""

##################################################
# Configurar Docker para iniciar automaticamente #
##################################################
echo ""
print_with_line "$msg_docker_init_auto" "yellow;bold;default"
echo ""

sudo systemctl enable docker.service
sudo systemctl enable containerd.service
echo ""
echo "$msg_docker_init_auto_ok"
echo ""

#########################
# Obter o IP da máquina #
#########################
echo ""
print_with_line "$msg_obter_ip" "yellow;bold;default"
echo ""

IP_ADDR=$(hostname -I | awk '{print $1}')

if [ -z "$IP_ADDR" ]; then
    format_multi_part_text "$msg_obter_ip_erro\n;red;bold;default"
    exit 1
else
    echo -e "$msg_obter_ip_ok $IP_ADDR"
fi
echo ""

##################################################
# Verificar se Docker Swarm já está inicializado #
##################################################
echo ""
print_with_line "$msg_docker_swarm" "yellow;bold;default"
echo ""

if docker info | grep -q "Swarm: active"; then
    echo ""
    format_multi_part_text "$msg_docker_swarm_pular\n;yellow;italic;default"
else
    docker swarm init --advertise-addr=$IP_ADDR
    echo ""
    if [ $? -eq 0 ]; then
        echo -e "$msg_docker_swarm_ok"
    else
        format_multi_part_text "$msg_docker_swarm_erro\n;red;bold;default"
        exit 1
    fi
fi
echo ""

##########################
# Verificar/criar a rede #
##########################
echo ""
print_with_line "$msg_docker_network_swarm" "yellow;bold;default"
echo ""

if docker network ls | grep -q "network_swarm_public"; then
    format_multi_part_text "$msg_docker_network_swarm_pular\n;yellow;italic;default"
else
    docker network create --driver=overlay network_swarm_public
    echo ""
    if [ $? -eq 0 ]; then
        echo -e "$msg_docker_network_swarm_ok"
    else
        format_multi_part_text "$msg_docker_network_swarm_erro\n;red;bold;default"
        exit 1
    fi
fi
echo ""

###########################
# Deploy stack do Traefik #
###########################
echo ""
print_with_line "$msg_stack_traefik_deploy" "yellow;bold;default"
echo ""

docker stack deploy --prune --detach=false --resolve-image always -c stack-traefik-v2.yml traefik
echo ""

if [ $? -eq 0 ]; then
    echo -e "$msg_stack_traefik_deploy_ok"
else
    format_multi_part_text "$msg_stack_traefik_deploy_erro\n;red;bold;default"
    exit 1
fi
echo ""

#############################
# Deploy stack do Portainer #
#############################
echo ""
print_with_line "$msg_stack_portainer_deploy" "yellow;bold;default"
echo ""

docker stack deploy --prune --detach=false --resolve-image always -c stack-portainer.yml portainer
echo ""

if [ $? -eq 0 ]; then
    echo -e "$msg_stack_portainer_deploy_ok"
else
    format_multi_part_text "$msg_stack_portainer_deploy_erro\n;red;bold;default"
    exit 1
fi
echo ""

#----------------------------------------------------------------------------------
# Função para verificar se o Portainer está ativo e pronto para receber requisições
#----------------------------------------------------------------------------------
wait_for_portainer() {
    local RETRIES=20 # Número máximo de tentativas
    local DELAY=5    # Intervalo entre tentativas (em segundos)
    local attempt=0  # Contador de tentativas

    format_multi_part_text "$msg_portainer_verificando\n;yellow;italic;default"
    echo ""

    # Loop até que o Portainer esteja disponível ou o número máximo de tentativas seja atingido
    while [ $attempt -lt $RETRIES ]; do
        # Tentar acessar o endpoint de status do Portainer
        status=$(curl -s -o /dev/null -w "%{http_code}" "$PORTAINER_URL_LOCAL_API/api/status")

        # Se o status for 200, o Portainer está ativo
        if [[ "$status" -eq 200 ]]; then
            return 0
        else
            attempt=$((attempt + 1))

            # Substituir variáveis nas mensagens
            local msg_tentativa=${msg_portainer_verificando_tentativa//_ATTEMPT_/$attempt}
            local msg_tentativa=${msg_tentativa//_RETRIES_/$RETRIES}

            format_multi_part_text "$msg_tentativa\n;cyan;italic;default"

            # Chamar a função aguardar passando o tempo de espera
            aguardar $DELAY
            echo ""
        fi
    done

    format_multi_part_text "$msg_portainer_falha_completa\n;white;default;default"
    return 1
}

########################################
# Esperar o Portainer ficar disponível #
########################################
if wait_for_portainer; then
    format_multi_part_text "$msg_portainer_disponivel\n;yellow;default;default"
else
    echo ""
    format_multi_part_text "$msg_encerrando_script\n;red;bold;default"
    exit 1
fi
echo ""

############################################
# Portainer API - Definindo senha do admin #
############################################
echo ""
print_with_line "$msg_portainer_definir_senha_admin" "yellow;bold;default"
echo ""

# Definir a senha do admin usando o endpoint de inicialização
admin_init_response=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"Username\":\"admin\",\"Password\":\"$CHANGE_PORTAINER_ADMIN_PASSWORD\"}" \
    "$PORTAINER_URL_LOCAL_API/api/users/admin/init")

debug_log "Retorno da chamada admin/init\n;yellow;italic;default"
debug_log "$admin_init_response"
debug_log "\n"

# Verificar se houve algum erro
if [[ "$admin_init_response" == *"err"* || "$admin_init_response" == *"error"* ]]; then
    format_multi_part_text "$msg_portainer_definir_senha_admin_erro\n;red;bold;default"
    debug_log "$admin_init_response"
    debug_log "\n"
    exit 1
else
    echo -e "$msg_portainer_definir_senha_admin_ok"
fi
echo ""

###############################################################
# Portainer API - Autenticar no Portainer e obter o token JWT #
###############################################################
echo ""
print_with_line "$msg_portainer_autenticacao_token" "yellow;bold;default"
echo ""

auth_response=$(
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"Username\":\"admin\",\"Password\":\"$CHANGE_PORTAINER_ADMIN_PASSWORD\"}" \
        "$PORTAINER_URL_LOCAL_API/api/auth"
)

debug_log "Retorno da autenticação no Portainer:\n;yellow;italic;default"
debug_log "$auth_response"
debug_log "\n"

# Extrair o token do JSON de resposta
PORTAINER_TOKEN=$(echo $auth_response | jq -r .jwt)

# Verificar se o token foi obtido corretamente
if [[ "$PORTAINER_TOKEN" == "null" ]]; then
    echo -e "$msg_portainer_autenticacao_token_erro"
    echo ""
    exit 1
fi

echo -e "$msg_portainer_autenticacao_token_ok"
echo ""
echo ""

#------------------------------
# Função Deploy Stack Portainer
#------------------------------
deploy_stack_portainer() {
    local STACK_NAME=$1
    local COMPOSE_FILE_PATH=$2

    format_multi_part_text "$msg_fazendo_deploy_stack ;yellow;underline;default" "$STACK_NAME\n\n;white;underline;default"

    # Obter o Swarm ID
    SWARM_ID=$(curl -s -H "Authorization: Bearer $PORTAINER_TOKEN" \
        "$PORTAINER_URL_LOCAL_API/api/endpoints/1/docker/swarm" | jq -r '.ID')

    # Verificar se o Swarm ID foi obtido corretamente
    if [[ -z "$SWARM_ID" ]]; then
        format_multi_part_text "$msg_nao_obteve_swarm_id\n;red;bold;default"
        return 1
    fi

    # Enviar a stack para o Portainer como um arquivo
    response=$(
        curl -s -X POST "$PORTAINER_URL_LOCAL_API/api/stacks/create/swarm/file?endpointId=1" \
            -H "Authorization: Bearer $PORTAINER_TOKEN" \
            -F "Name=$STACK_NAME" \
            -F "SwarmID=$SWARM_ID" \
            -F "file=@$COMPOSE_FILE_PATH"
    )

    # Exibir a resposta da API para depuração
    debug_log "$msg_resposta_api_portainer\n;yellow;italic;default"
    debug_log "$response"
    debug_log "\n"

    # Verificar se a resposta contém erros
    if [[ $response == *"err"* || $response == *"error"* ]]; then
        format_multi_part_text "$msg_erro_implantar_stack ;red;bold;default" "$STACK_NAME\n;white;default;default"
        exit 1
    else
        format_multi_part_text "✅ Stack ;yellow;italic;default" "$STACK_NAME;white;default;default" " $msg_stack_implantada_sucesso\n;yellow;italic;default"
    fi
}

#-----------------------------------------
# Função para exibir o contador e aguardar
#-----------------------------------------
aguardar() {
    local segundos=$1

    for ((i = 1; i <= segundos; i++)); do
        # Mostra o contador na mesma linha
        eval echo -ne "$msg_aguardando\r"
        sleep 1
    done

    # Garante que a próxima linha seja exibida corretamente
    echo ""
}

#-------------------------------------------------
# Função para verificar se o MySQL está disponível
#-------------------------------------------------
wait_for_mysql() {
    local MYSQL_HOST=$1
    local MYSQL_USER=$2
    local MYSQL_PASSWORD=$3
    local RETRIES=20 # Número máximo de tentativas
    local DELAY=5    # Intervalo entre tentativas (em segundos)
    local attempt=0  # Contador de tentativas

    # Substituindo as variáveis nas mensagens com os valores atuais
    local msg_mysql_falha_completa=${msg_mysql_falha//_RETRIES_/$RETRIES}

    format_multi_part_text "$msg_mysql_verificando\n;yellow;italic;default"
    echo ""

    # Loop até que o MySQL esteja disponível ou o número máximo de tentativas seja atingido
    while [ $attempt -lt $RETRIES ]; do
        if mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
            echo "$msg_mysql_disponivel"
            echo ""
            return 0
        else
            attempt=$((attempt + 1))

            # Substitui _ATTEMPT_ e _RETRIES_ na mensagem
            local msg_tentativa=${msg_mysql_verificando_segundos//_ATTEMPT_/$attempt}
            local msg_tentativa=${msg_tentativa//_RETRIES_/$RETRIES}

            format_multi_part_text "$msg_tentativa\n;cyan;italic;default"

            # Chama a função aguardar passando a mensagem atualizada
            aguardar $DELAY
            echo ""
        fi
    done

    echo "$msg_mysql_falha_completa"
    return 1
}

########################################
# Deploy stack MySql via Portainer API #
########################################
STACK_MYSQL_NAME="mysql_mautic"
COMPOSE_MYSQL_PATH="stack-mysql-mautic.yml"

deploy_stack_portainer "$STACK_MYSQL_NAME" "$COMPOSE_MYSQL_PATH"
echo ""
echo ""

#########################################
# Deploy stack Mautic via Portainer API #
#########################################
STACK_MAUTIC_NAME="mautic"
COMPOSE_MAUTIC_PATH="stack-mautic.yml"

# Aguardar o MySQL ficar disponível
if wait_for_mysql "127.0.0.1" "root" "$CHANGE_MYSQL_ROOT_PASSWORD"; then
    # Deploy do Mautic se o MySQL estiver disponível
    echo ""
    deploy_stack_portainer "$STACK_MAUTIC_NAME" "$COMPOSE_MAUTIC_PATH"
else
    echo ""
    format_multi_part_text "$msg_deploy_mautic_cancelado_mysql\n;red;bold;default"
    exit 1
fi
echo ""

echo -e "\n$msg_script_executado_ok"
echo ""
