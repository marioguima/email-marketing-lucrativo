# Solicita o e-mail do usuário
echo "Por favor, insira o seu e-mail para configurar o Let's Encrypt no Traefik:"
read USER_EMAIL

# Verifica se o e-mail foi inserido
if [ -z "$USER_EMAIL" ]; then
    echo "Erro: O e-mail não pode estar vazio."
    exit 1
fi

# Substitui o e-mail no arquivo stack-traefik-v2.yml
echo "Substituindo o e-mail no arquivo de stack do Traefik..."
sed -i "s/meuemail@email.com/$USER_EMAIL/" stack-traefik-v2.yml

# Verifica se a substituição foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "E-mail substituído com sucesso."
else
    echo "Erro: Falha ao substituir o e-mail."
    exit 1
fi

# # Executa o Stack do Traefik v2
# echo "Executando o Stack do Traefik v2..."
# docker stack deploy --prune --detach=false --resolve-image always -c stack-traefik-v2.yml traefik

# if [ $? -eq 0 ]; then
#     echo "Stack do Traefik implantada com sucesso."
# else
#     echo "Erro: Falha ao implantar a stack do Traefik."
#     exit 1
# fi