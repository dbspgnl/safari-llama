@echo off
set IMAGE_NAME=llama-server:latest
set BASE_IMAGE=llama-base:latest
set CONTAINER_NAME=llama_api

:: Dockerfile.base 이미지가 존재하는지 확인하고, 없으면 빌드
docker image inspect %BASE_IMAGE% >nul 2>&1
if %errorlevel% neq 0 (
    echo "llama-base 이미지가 없으므로 새로 빌드합니다..."
    docker build -f "%cd%/Dockerfile.base" -t %BASE_IMAGE% .
)

:: Dockerfile.app으로 llama-server 이미지 빌드
echo "llama-server 이미지를 빌드합니다..."
docker build -f "%cd%/Dockerfile.app" -t %IMAGE_NAME% .

:: 기존 컨테이너 중지 및 삭제
docker stop %CONTAINER_NAME%
docker rm %CONTAINER_NAME%

:: 컨테이너 실행 (GPU 사용 설정 포함)
docker run --gpus all ^
  --name %CONTAINER_NAME% ^
  -v %cd%/models:/app/models ^
  -v %cd%/main.py:/app/main.py ^
  -e NVIDIA_VISIBLE_DEVICES=all ^
  -p 8000:8000 ^
  %IMAGE_NAME%

:: 오류 확인용 일시 정지
if %errorlevel% neq 0 (
    echo "오류가 발생했습니다. 로그를 확인하세요."
) else (
    echo "컨테이너가 성공적으로 실행되었습니다."
)
pause
