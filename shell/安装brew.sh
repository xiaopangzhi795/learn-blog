/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


brew install zsh

echo $SHELL

cat /etc/shells

chsh -s /bin/zsh


sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


plugins=(git osx autojump zsh-autosuggestions zsh-syntax-highlighting)
