#!/bin/bash
#-----------------------------------------------------
#  Arquivo:       install.sh
#  Descricao:     Instalador de utilitários para Ubuntu
#  Autor:         Salomão Neto <salomaosnff3@gmail.com>
#----------------------------------------------------

TMP="$HOME/.installer-tmp";
PV_FORMAT="%b %p %e "

# Packages config
PHPSTORM='https://download.jetbrains.com/webide/PhpStorm-2017.1.4.tar.gz'
PHPSTORM_DIR='/opt/phpstorm'
VSCODE='https://go.microsoft.com/fwlink/?LinkID=760868'
NODEJS_PPA_SCRIPT='https://deb.nodesource.com/setup_6.x'
SLACK='https://downloads.slack-edge.com/linux_releases/slack-desktop-2.6.2-amd64.deb'
TEAMVIEWER='https://download.teamviewer.com/download/teamviewer_i386.deb'
THEME_PATH="$HOME/.themes"

# -----------------------------------------------------------------------
# --------------------------- Functions ---------------------------------
# -----------------------------------------------------------------------
# Adicione aqui funções adicionais
# -----------------------------------------------------------------------

# É root/sudo?
isRoot(){
	if [[ $EUID -ne 0 ]]; then
   		echo "Execute esse script com o sudo." 1>&2
   		exit 1
	fi
}

# Entra em uma pasta, se ela não existir ela será criada
mkcd(){
	mkdir -p $1
	cd $1
}

# Baixa um arquivo e salva como um nome
download(){
	echo "Fazendo download de $1..."
	curl -# -L -o $2 $1
}

# Executa um arquivo
run(){
	chmod +x $1
	bash $1
}

# -----------------------------------------------------------------------
# -------------------------- Installers ---------------------------------
# -----------------------------------------------------------------------
# Crie/Adicione aqui o script de instalação de programas adicionais
# -----------------------------------------------------------------------

# Instalação do tema
install_theme(){
	mkcd $THEME_PATH
	rm -rf "macOS Sierra"
	echo "Instalando tema MacOS Sierra..."

	git clone https://github.com/B00merang-Project/macOS-Sierra.git

	echo "Ativando o tema..."
	xfconf-query -c xsettings -p /Net/ThemeName -s "macOS Sierra"
	xfconf-query -c xfwm4 -p /general/theme -s "macOS Sierra"
}

# Instalação do PhpStorm
install_phpstorm(){
	mkcd $TMP
	rm -rf $PHPSTORM_DIR
	echo "Instalando o PhpStorm..."
	download $PHPSTORM phpstorm.tar.gz
	mkdir $PHPSTORM_DIR
	echo $(pv phpstorm.tar.gz -p | tar xzf - -C $PHPSTORM_DIR --strip-components 1)
	# tar zxfv phpstorm.tar.gz -C $PHPSTORM_DIR --strip-components 1
	echo "Execute $PHPSTORM_DIR/bin/phpstorm.sh para configurar"
}

# Instalação do Visual Studio Code
install_vscode(){
	mkcd $TMP
	echo "Instalando Visual Studio Code..."
	download $VSCODE vscode.deb
	dpkg -i vscode.deb
}

# Node Modules
install_npm_modules(){
	echo "Instalando módulos do NPM..."
	npm install -g yarn stylus webpack gulp nodemon
}

# Slack
install_slack(){
	echo "Instalando o slack"
	mkcd $TMP
	download $SLACK slack.deb
	dpkg -i slack.deb
}

install_teamviewer(){
	echo "Instalando o Teamviewer..."
	mkcd $TMP
	download $TEAMVIEWER teamviewer.deb
	dpkg -i teamviewer.deb
}
# -----------------------------------------------------------------------
# ------------------------------ Scripts --------------------------------
# -----------------------------------------------------------------------
# Adicione aqui todas os scripts a serem 
# executados antes do install
# -----------------------------------------------------------------------
start(){
	# Se não for Root/Sudo, fechar.
	isRoot

 	# Cria uma pasta temporária
	mkcd $TMP
	echo "Ativando Repositórios e adicionando chaves..."
	
	# PPA: Papper Icons
	echo "Ativando PPA para Papper Icons..."
	add-apt-repository ppa:snwh/pulp -y
	
	# KEY: MongoDB
	echo "Adicionando chave para MongoDB..."
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
	echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
	
	# PPA: Node JS
	echo "Adicionando PPA para Node JS..."
	mkcd ~/.tmp
	download $NODEJS_PPA_SCRIPT nodejs.sh
	run nodejs.sh

	# Remove OpenJDK
	apt-get purge openjdk*
	
	# PPA: Java (Oracle)
	add-apt-repository ppa:webupd8team/java -y

}

# Adicione aqui pacotes a serem instalados após o "-y"
install_packages(){

	apt-get update
	apt-get install -y pv curl git gimp inkscape transmission paper-icon-theme nodejs mongodb-org oracle-java8-installer

	# -----------------------------
	# - Instaladores customizados -
	# -----------------------------

	install_npm_modules
	install_vscode
	install_slack
	install_teamviewer
	install_phpstorm
	install_theme
	
}

# Scripts de finalização
finish(){
	# Inicia e habilita a inicialização do MongoDB no boot
	systemctl enable mongod
	systemctl start mongod

	# Remove a pasta temporária
	rm -rf $TMP
}

# -----------------------------------------------------------------------
# Não alterar desta linha para baixo

start
install_packages
finish
