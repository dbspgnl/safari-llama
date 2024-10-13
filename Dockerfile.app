# dockerfile.app

# llama-base 이미지를 사용하여 torch 및 transformers 캐시
FROM llama-base:latest

# 모델과 main.py 파일을 컨테이너에 복사
WORKDIR /app
COPY ./models /app/models
COPY ./main.py /app/main.py

# 포트 공개
EXPOSE 8000

# FastAPI 서버 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
