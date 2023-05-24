
 ## 1 - Baixar os arquivos do adsys diretamente no repositório do Ubuntu

 ### Acesse o repositório do Ubuntu e baixxe os arquivos necessários

 * Repositório  https://github.com/ubuntu/adsys/tree/main/policies/Ubuntu/all
 * Arquivo `Ubuntu.adml`  https://github.com/ubuntu/adsys/blob/main/policies/Ubuntu/all/Ubuntu.adml
 * Arquivo `Ubuntu.admx`  https://github.com/ubuntu/adsys/blob/main/policies/Ubuntu/all/Ubuntu.admx

 ## 2 - Criação das políticas no Active Directory
 
 ### Acesse o diterório no seu Active Directory
 ```
 C:\Windows\SYSVOL\domain\Policies
 ```
 > Em domain, informe o nome do seu domínio

 ### Crie uma pasta para a inclusão do arquivo Ubuntu.admx
 ```
 PolicyDefinitions
 ```

 ### Dentro da pasta PolicyDefinitions, crie uma pasta en-US e inclua o arquivo Ubuntu.adml
 ```
 C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions\en-US\
 ```

 ## 3 - Configurar as políticas
 Na aba Tools, no servidor que está instalado o Active Directory, acesse a aba Group Policy Manegemant, em seguida crie uma nova unidade organizacional clicando com o botão direito no nome do domínio

 1. Nomeie a unidade com o nome `Linux-computers`
 2. Crie uma GPO dentro da unidade **Linux-computers** clicando com o botao direito e atribua o nome **Ubuntu** para a GPO
 

 ## 4 - Execução de comandos no linux

 ### Adicionando o computador
 ```shell
 realm join -v domain.local -U user --computer-ou=OU=Linux-computers
 ```

 ## 5 - Configurando kerberos 

 Edite o arquivo **/etc/sssd/sssd.conf** e incluia o conteúdo abaixo

```shell
[sssd]
domains = dominio.com
config_file_version = 2
services = nss, pam
default_domain_suffix = domain.com

[domain/domain.com]
enumerate = false
default_shell = /bin/bash
krb5_store_password_if_offline = false
cache_credentials = True
krb5_realm = DOMAIN.COM
realm_tags = manages-system joined-with-adcli
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = domain.com
use_fully_qualified_names = True
ldap_id_mapping = True
access_provider = ad
auth_provider = ad
chpass_provider = ad
dyndns_update = false
ldap_schema = ad
ldap_id_mapping = true
ldap_sasl_mech = gssapi
krb5_keytab = /etc/krb5.keytab
ldap_krb5_init_creds = true
cache_credentials = true
account_cache_expiration = 14
entry_cache_timeout = 14400
krb5_store_password_if_offline = true
user_fully_qualified_names = false
ad_gpo_access_control = permissive

[pam]
reconnection_retries = 3
debug_level = 10
offline_credentials_expiration = 3

[nss]
filter_groups = root
filter_users = root
reconnection_retries = 3
```

### Execute o seguinte comando
```shell
sudo apt install krb5-user adsys libpam-krb5 -y
```

Edite o arquivo **/etc/krb5.conf** e incluia o conteúdo abaixo

```shell
[libdefaults]
default_realm = domain.com
rdns = false
dns_lookup_kdc = true
dns_lookup_realm = true
default_ccache_name = FILE:/home/%{username}/krb5cc
ticker_lifetime = 24h
renew_lifetime = 7d
forwardable = true
udp_preference_limit = 0

[realms]
DOMAIN.COM = {
default_domain = DOMAIN.COM
}
```

Definir permissão do arquivo
sudo chmod 0600 /etc/krb5.keytab; chown root:root /etc/krb5.keytab; sudo ua attach token


descomentar linha do arquivo
nano /etc/apparmor.d/tunables/home.d/site.local

Antes
#{HOMEDIRS}+=/srv/nfs/home/ /mnt/home

Depois
{HOMEDIRS}+=/home/domain.com/ /home/


Editar arquivo
nano /etc/pam.d/common-sessions

incluir no final da linha
session required pam_mkhomedir.so skel=/etc/skel/ umask=077


Editar arquivo 
nano /etc/pam.d/common-account

incluir no final da linha
session required pam_mkhomedir.so skel=/etc/skel/ umask=0022

Executar comando
sudo ua attach

Reiniciar a máquina



Executar comandos
systemctl restart realmd sssd
adsysctl update -m -vv