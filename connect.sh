#!/bin/bash
#------------------------------------------------------
# Data:        20/05/22
# Criado por:  Rafael Vinícius
# Descrição:   Describe Instance ec2 and connect.
# Github:      https://github.com/faelvinicius/
#------------------------------------------------------

# Variaveis
KEY_PAIR="~/keypair.pem" #path e keypair name .pem
SSH_USER="ubuntu" #user conexão ec2 example: centos, ec2-user, ubuntu

echo "======================================================================================================"
echo -e "                               \e[1;33mAcesso SSH em Instancias EC2 AWS\e[0m"
echo "======================================================================================================"
echo -e "\e[1;33mBem vindo! \e[0m"
echo -e "\033[1;31mAntes de utilizar o script, é necessário configurar o AWSCLI no seu computador e configurar a\nAWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY.\n\033[\e[0m"
echo -e "\e[1;33mPara utilizar o script é necessário configurar as seguintes variaveis:\nKEY_PAIR passando o path e nome da chave .pem que será utilzada para realizar o ssh.\nSSH_USER que é referente ao usuário que tem permissão para o acesso SSH nas instâncias. \e[0m"
echo "======================================================================================================="

# Função para listar as instâncias em state running e a quantidade de instâncias running.
list_instances()
{
INSTANCES=$(aws ec2 describe-instances --region $AWS_REGION \
--query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,KeyPair:KeyName}"  \
--filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values='*'"  \
--output table)

echo "$INSTANCES"

INSTANCE_COUNT=$(aws ec2 describe-instances --region "$AWS_REGION" --query "Reservations[*].Instances[*].Tags[?Key=='Name']" --filters "Name=instance-state-name,Values=running" --output text | wc -l)
echo -e "\e[1;32mQuantidade de Instâncias Running: $INSTANCE_COUNT\e[0m"
}

#Função para realizar a conexão ssh na instância selecionada.
connect()
{
echo "======================================================================================================="

echo -e "\e[1;34mQual instância gostaria de se conectar via ssh?\e[1;32m[exemplo: Instance Name]\e[0m \e[0m"
read INSTANCE_NAME

INSTANCE_IP=$(aws ec2 describe-instances --region $AWS_REGION --query "Reservations[*].Instances[*].PrivateIpAddress"  --filter Name=tag:Name,Values=$INSTANCE_NAME --output text)

ssh -i "$KEY_PAIR" "$SSH_USER@$INSTANCE_IP"
}


# Menu interativo para escolha da região.
PS3='Para listar as instâncias, digite o número referente a Região: '
options=(
          "us-east-1"
          "us-east-2"
          "sa-east-1"                                                                        
          "Quit")


select opt in "${options[@]}"
do
    case $opt in
        "us-east-1")
           AWS_REGION="us-east-1"
           list_instances
           connect
           exit
            ;;
        "us-east-2")
           AWS_REGION="us-east-2"
           list_instances
           connect
           exit
            ;;   
        "sa-east-1")
           AWS_REGION="sa-east-1"
           list_instances
           connect
           exit
            ;;                                                                                                                                                                                                                                         
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done





