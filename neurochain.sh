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

# 선택에 따른 작업 수행
if [ "$option" == "1" ]; then
    echo -e "${YELLOW}NVIDIA 드라이버 설치 옵션을 선택하세요:${NC}"
    echo -e "1: 일반 그래픽카드 (RTX, GTX 시리즈) 드라이버 설치"
    echo -e "2: 서버용 GPU (T4, L4, A100 등) 드라이버 설치"
    echo -e "3: 기존 드라이버 및 CUDA 완전 제거"
    echo -e "4: 드라이버 설치 건너뛰기"
    
    while true; do
        read -p "선택 (1, 2, 3, 4): " driver_option
        
        case $driver_option in
            1)
                sudo apt update
                sudo apt install -y nvidia-utils-550
                sudo apt install -y nvidia-driver-550
                sudo apt-get install -y cuda-drivers-550 
                sudo apt-get install -y cuda-12-3
                ;;
            2)
                distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
                wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-keyring_1.0-1_all.deb
                sudo dpkg -i cuda-keyring_1.0-1_all.deb
                sudo apt-get update
                sudo apt install -y nvidia-utils-550-server
                sudo apt install -y nvidia-driver-550-server
                sudo apt-get install -y cuda-12-3
                ;;
            3)
                echo "기존 드라이버 및 CUDA를 제거합니다..."
                sudo apt-get purge -y nvidia*
                sudo apt-get purge -y cuda*
                sudo apt-get purge -y libnvidia*
                sudo apt autoremove -y
                sudo rm -rf /usr/local/cuda*
                echo "드라이버 및 CUDA가 완전히 제거되었습니다."
                ;;
            4)
                echo "드라이버 설치를 건너뜁니다."
                break
                ;;
            *)
                echo "잘못된 선택입니다. 다시 선택해주세요."
                continue
                ;;
        esac
        
        if [ "$driver_option" != "4" ]; then
            echo -e "\n${YELLOW}NVIDIA 드라이버 설치 옵션을 선택하세요:${NC}"
            echo -e "1: 일반 그래픽카드 (RTX, GTX 시리즈) 드라이버 설치"
            echo -e "2: 서버용 GPU (T4, L4, A100 등) 드라이버 설치"
            echo -e "3: 기존 드라이버 및 CUDA 완전 제거"
            echo -e "4: 드라이버 설치 건너뛰기"
        fi
    done

            # CUDA 툴킷 설치 여부 확인
        if command -v nvcc &> /dev/null; then
            echo -e "${GREEN}CUDA 툴킷이 이미 설치되어 있습니다.${NC}"
            nvcc --version
            read -p "CUDA 툴킷을 다시 설치하시겠습니까? (y/n): " reinstall_cuda
            if [ "$reinstall_cuda" == "y" ]; then
                # dpkg 문제 해결을 위한 자동 실행
                sudo dpkg --configure -a
                sudo apt-get update
                sudo apt-get install -f -y
                sudo apt-get install -y nvidia-cuda-toolkit
            fi
        else
            echo -e "${YELLOW}CUDA 툴킷을 설치합니다...${NC}"
            # dpkg 문제 해결을 위한 자동 실행
            sudo dpkg --configure -a
            sudo apt-get update
            sudo apt-get install -f -y
            sudo apt-get install -y nvidia-cuda-toolkit
        fi

echo -e "${GREEN}Neurochain 노드 설치 및 구동을 시작합니다.${NC}"
echo -e "${GREEN}정상적으로 구동되기 시작하면 컨트롤+AD로 스크린을 빠져나오신 후 창을 종료해주세요.${NC}"
echo -e "${YELLOW}대시보드사이트는 다음과 같습니다:https://app.neurochain.ai/my-assets${NC}"
echo -e "${BLUE}스크립트작성자: https://t.me/kjkresearch${NC}"
read -p "계속하시려면 엔터를 눌러주세요: "

# 필수 패키지 설치
sudo apt-get update && sudo apt-get install unzip -y
sudo apt-get install git build-essential

# 디렉토리 생성 및 이동
mkdir neurochain
cd neurochain
wget https://worker-files.neurochain.ai/linux-1.3.0.zip
sudo unzip linux-1.3.0.zip

# 8GB 스왑 파일 생성
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 영구적으로 스왑 설정 (재부팅 후에도 유지)
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sleep 5
export SIGNATURE=$signature

# 모든 파일과 디렉토리의 소유권을 현재 사용자로 변경
sudo chown -R $USER:$USER .

# 필요한 디렉토리에 쓰기 권한 추가
sudo chmod -R 755 _internal
sudo chmod -R 755 .
# 노드 실행
./worker
