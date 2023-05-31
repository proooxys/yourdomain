!#/usr/bin/sh

echo "--------------------------------------------------------------------------"
echo "-------------Script de configuração de domínio Active Directory-----------"
echo "--------------------------------------------------------------------------"
echo
echo "Baseado em: https://ubuntu.com/server/docs/service-sssd-ad"
echo
echo "--------------------------------------------------------------------------"
echo " [+] - 1. Executar instalação e configuração inicial"
echo " [+] - 2. Sair do programa!"

echo "Selecione uma opção..."
    read -p -n 1 resp
    case $resp in

    1) # Opção [1] - Executar instalação e configuração inicial

        # Instalando pacotes necessários
        echo -e "[=] - Instalando pacotes..."
            sudo apt install sssd-ad sssd-tools realmd adcli -y

        # Verificando detecção do AD via DNS
        echo -e "[=] - Verificando se o domínio é detectado via DNS."
            echo -e "Digite o domínio:"
            read -p AdDiscover
            realm -v discover $AdDiscover

        # Ingressando no domínio
        echo -e "[=] - Ingressar no domínio..."
        echo
        echo -e "Obs: Deve ser inserido inicialmente um usuário com permisão de administrador do domínio"
        echo -e "[=] - Digite o nome de usuário:"
        read -p usuario
        echo -e "[=] - Digite o nome de domínio:"
            read dominio
            realm join -U $usuario $dominio -v

        # Habilitando a criação automárica de diretórios
        echo -e"[=] - habilitando a criação de diretórios"
        echo
            pam-auth-update --enable mkhomedir

        # Verificar iformações do usuário no AD
        echo "[=] - Verificar informações do usuário no AD"
        echo
            getent passwd $usuario@$dominio
        
        # Verificar iformações de grupo do usuário no AD
        echo "[=] - Verificar informações de grupo do usuário"
        echo
            groups $usuario@$dominio
        
        # Testar autenticação de login e criação do diretório raiz
        echo "[=] - Testar autenticação do usuário e criação do diretório raiz"
        echo
            sudo login $usuario@$dominio
        
        ;;

        2) # Sair
        ;;

esac
;;