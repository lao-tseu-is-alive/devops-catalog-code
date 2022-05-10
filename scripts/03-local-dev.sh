####################################################
# Installing The Windows Subsystem for Linux (WSL) #
####################################################

# Only if Windows
sudo apt-add-repository ppa:git-core/ppa

# Only if Windows
sudo apt update

# Only if Windows
sudo apt install curl git

# Only if Windows
exit

####################
# Choosing A Shell #
####################

# Only if using Ubuntu, Debian, or WSL
sudo apt install \
    zsh powerline fonts-powerline

# Only if using macOS
brew install zsh

sh -c "$(curl -fsSL \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

######################
# A Short Intermezzo #
######################

# Only if using Ubuntu, Debian, or WSL
sudo apt install xdg-utils

# Only if using Ubuntu, Debian, or WSL
alias open='xdg-open'

# Only if using Ubuntu, Debian, or WSL
open https://www.devopstoolkitseries.com

# Only if using Ubuntu, Debian, or WSL
echo "alias open='xdg-open'" \
    | tee -a $HOME/.zshrc

##################################
# Choosing An IDE And A Terminal #
##################################

open https://code.visualstudio.com/download

#########################
# Configuring Oh My ZSH #
#########################

ls -1 $HOME/.oh-my-zsh/plugins

ls -1 $HOME/.oh-my-zsh/plugins \
    | grep kubectl

ls -1 $HOME/.oh-my-zsh/custom/plugins

git clone \
    https://github.com/zsh-users/zsh-autosuggestions \
    $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions

vim $HOME/.zshrc

# Replace `plugins=(git)` with the snippet in the comments (without the comments).

# plugins=(
#   git
#   kubectl
#   minikube
#   zsh-autosuggestions
#   helm
# )

exit

#########################################
# Going For A Test Drive With Oh My Zsh #
#########################################

mkdir code

cd code

git clone https://github.com/vfarcic/devops-catalog-code.git

cd devops-catalog-code

git checkout -b something

git checkout master

kubectl --namespace kube-system \
    describe pod [...]
