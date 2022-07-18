#!/bin/bash

# Versions
PYTHON_VERSION=3.10.4
NVM_VERSION=0.39.1
NODE_VERSION=16.15.1
KUBECTL_VERSION=1.24.3
AWSVAULT_VERSION=6.6.0
TERRAFORM_VERSION=1.2.5
TERRAGRUNT_VERSION=0.38.4

# Oh My Bash Configuration
sed -i 's/OSH_THEME="font"/OSH_THEME="90210"/g' $HOME/.bashrc

# Needed base files creation
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.ssh/github/
mkdir -p $HOME/.ssh/gitlab/
mkdir -p $HOME/.ssh/bitbucket/
touch $HOME/.ssh/config

# Direnv configuration
DIRENV_CONFIG="$HOME/.direnv_config"
rm -rf $DIRENV_CONFIG && touch $DIRENV_CONFIG
cat <<EOT >> $DIRENV_CONFIG
# Direnv configuration
eval "\$(direnv hook bash)"

EOT
. $DIRENV_CONFIG

# Setting up SSH
SSH_CONFIG="$HOME/.ssh_config"
rm -rf $SSH_CONFIG && touch $SSH_CONFIG
cat <<EOT >> $SSH_CONFIG
# SSH Configuration
SSH_ENV="\$HOME/.ssh/env"
rm -rf \$SSH_ENV

function run_ssh_env {
  . "\${SSH_ENV}" > /dev/null
}

function start_ssh_agent {
  echo "Initializing new SSH agent..."
  ssh-agent | sed 's/^echo/#echo/' > "\${SSH_ENV}"
  echo "Succeeded"
  chmod 600 "\${SSH_ENV}"

  run_ssh_env;

  for FILE in \$HOME/.ssh/github/*; do ssh-add \$FILE; done;
  for FILE in \$HOME/.ssh/gitlab/*; do ssh-add \$FILE; done;
  for FILE in \$HOME/.ssh/bitbucket/*; do ssh-add \$FILE; done;
}

if [ -f "\${SSH_ENV}" ]; then
  run_ssh_env;
  ps -ef | grep \${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_ssh_agent;
  }
else
  start_ssh_agent;
fi

EOT
. $SSH_CONFIG

# Installing Python
curl https://pyenv.run | bash
rm -rf $HOME/.pyenv
PYENV_CONFIG="$HOME/.pyenv_config"
rm -rf $PYENV_CONFIG && touch $PYENV_CONFIG
cat <<EOT >> $PYENV_CONFIG
# Pyenv configuration
export PYENV_ROOT="\$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

EOT
. $PYENV_CONFIG
pyenv install $PYTHON_VERSION --force --verbose
pyenv global $PYTHON_VERSION

# Installing NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
NVM_CONFIG="$HOME/.nvm_config"
rm -rf $NVM_CONFIG && touch $NVM_CONFIG
cat <<EOT >> $NVM_CONFIG
# NVM configuration
export NVM_DIR="\$([ -z "\${XDG_CONFIG_HOME-}" ] && printf %s "\${HOME}/.nvm" || printf %s "\${XDG_CONFIG_HOME}/nvm")"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"

EOT
. $NVM_CONFIG
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION

# Installing AWS-CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf ./aws/ ./awscliv2.zip

# Installing ECS-CLI
sudo curl -Lo /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
chmod +x /usr/local/bin/ecs-cli

# Installing Heroku
curl https://cli-assets.heroku.com/install.sh | sh

# Installing Netlify CLI
npm install netlify-cli --location global --verbose

# Installing Kubectl
curl -LO "https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/v$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check
rm -rf kubectl.sha256
chmod +x kubectl
mv ./kubectl /usr/local/bin/kubectl

# Installing AWS-Vault
sudo curl -L -o /usr/local/bin/aws-vault https://github.com/99designs/aws-vault/releases/download/v$AWSVAULT_VERSION/aws-vault-linux-amd64
sudo chmod +x /usr/local/bin/aws-vault

# Installing Terraform
wget "https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo chmod +x terraform
sudo mv terraform /usr/local/bin/terraform
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Installing Terragrunt
wget "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
mv terragrunt_linux_amd64 terragrunt
sudo chmod +x terragrunt
sudo mv terragrunt /usr/local/bin/terragrunt

# Echo installed versions
PYTHON_VERSION_INSTALLED=$(python --version)
NVM_VERSION_INSTALLED=$(nvm --version)
NODE_VERSION_INSTALLED=$(node --version)
AWS_VERSION_INSTALLED=$(aws --version)
AWS_VAULT_VERSION_INSTALLED=$(aws-vault --version)
HEROKU_VERSION_INSTALLED=$(heroku --version)
NETLIFY_VERSION_INSTALLED=$(netlify --version)
ECS_CLI_VERSION_INSTALLED=$(ecs-cli --version)
KUBECTL_VERSION_INSTALLED=$(kubectl version --client)
TERRAFORM_VERSION_INSTALLED=$(terraform --version)
TERRAGRUNT_VERSION_INSTALLED=$(terragrunt --version)

cat << EOF
Current installed versions:

Python version: $PYTHON_VERSION_INSTALLED
NVM version: $NVM_VERSION_INSTALLED
Node version: $NODE_VERSION_INSTALLED
AWS version: $AWS_VERSION_INSTALLED
AWS-Vault version: $AWS_VAULT_VERSION_INSTALLED
Heroku version: $HEROKU_VERSION_INSTALLED
Netlify version: $NETLIFY_VERSION_INSTALLED
ECS-CLI version: $ECS_CLI_VERSION_INSTALLED
Kubectl version: $KUBECTL_VERSION_INSTALLED
Terraform version: $TERRAFORM_VERSION_INSTALLED
Terragrunt version: $TERRAGRUNT_VERSION_INSTALLED
EOF

# Prompt all needed to the bashrc
cat <<EOT >> $HOME/.bashrc
# Stateless configurations
. \$DIRENV_CONFIG
. \$SSH_CONFIG
. \$PYENV_CONFIG
. \$NVM_CONFIG
EOT
