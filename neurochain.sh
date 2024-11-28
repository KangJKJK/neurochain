#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Neurochain GPU 마이닝 설치 스크립트 ===${NC}"
echo
echo -e "${YELLOW}설치 단계:${NC}"
echo -e "${GREEN}1. https://app.neurochain.ai/referral/66946c93be1e2cf24f7d186f 에서 회원가입을 진행해주세요.${NC}"
echo -e "${GREEN}2. https://app.neurochain.ai/gpu-mining 에서 지갑을 연결하고 Signature 코드를 발급받으세요.${NC}"
echo

read -p "$(echo -e ${YELLOW}"Signature 코드를 입력해주세요: "${NC})" signature

# GPU 드라이버 설치 여부 확인
read -p "$(echo -e ${YELLOW}"GPU 드라이버가 이미 설치되어 있나요? (y/n): "${NC})" driver_installed

if [ "$driver_installed" == "y" ] || [ "$driver_installed" == "Y" ]; then
    echo -e "${GREEN}드라이버 설치 과정을 건너뛰고 진행합니다.${NC}"
else
    echo -e "${YELLOW}GPU 드라이버 설치를 진행합니다.${NC}"
    read -p "$(echo -e ${YELLOW}"GPU 종류를 선택하세요 (1: 일반 그래픽카드, 2: 서버용 GPU): "${NC})" gpu_type
    
    # GPU 타입에 따른 드라이버 설치
    sudo apt update
    if [ "$gpu_type" == "1" ]; then
        # 일반 그래픽카드용 드라이버 설치
        sudo apt install nvidia-utils-550
        sudo apt install nvidia-driver-550
        sudo apt-get install cuda-drivers-550    
    elif [ "$gpu_type" == "2" ]; then
        # 서버용 GPU 드라이버 설치
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
        wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-keyring_1.0-1_all.deb
        sudo dpkg -i cuda-keyring_1.0-1_all.deb
        sudo apt-get update
        sudo apt install nvidia-utils-550-server
        sudo apt install nvidia-driver-550-server
        sudo apt-get install cuda-drivers-550
        sudo apt-get install cuda
    else
        echo "잘못된 선택입니다."
        exit 1
    fi
fi

echo -e "${BLUE}마이닝 프로그램을 다운로드하고 설치합니다...${NC}"

# 필수 패키지 설치
sudo apt-get update && sudo apt-get install unzip -y
sudo apt-get install git build-essential

wget https://worker-files.neurochain.ai/linux-1.3.0.zip
unzip linux-1.3.0.zip
cd linux-1.3.0
export SIGNATURE=$signature
./server

echo -e "${GREEN}Neurochain 노드 설치가 완료되었습니다.${NC}"
echo -e "${GREEN}대시보드에서 확인하세요: https://app.neurochain.ai/gpu-mining${NC}"
echo -e "${BLUE}스크립트작성자: https://t.me/kjkresearch${NC}"