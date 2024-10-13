import torch
import time
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer
from torch.amp import autocast  # FP16 모드 사용을 위한 import

app = FastAPI()

# 모델 로드 함수
def load_model():
    model_path = "./models/models--meta-llama--Llama-3.2-3B-Instruct/snapshots/392a143b624368100f77a3eafaa4a2468ba50a72"
    device = "cuda" if torch.cuda.is_available() else "cpu"
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    model = AutoModelForCausalLM.from_pretrained(model_path).to(device)
    return tokenizer, model, device

# 모델과 토크나이저를 초기화해 글로벌 변수로 설정
tokenizer, model, device = load_model()

# 요청 데이터 구조 정의
class LlamaRequest(BaseModel):
    user_input: str

# Llama 모델 실행 함수
def run_llama_model(tokenizer, model, device, user_input):
    inputs = tokenizer(user_input, return_tensors="pt").to(device)
    with autocast(device_type='cuda'):
        start_time = time.time()
        outputs = model.generate(**inputs, max_length=30, top_p=0.8, top_k=50)
        end_time = time.time()
    response_time = end_time - start_time
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return response, response_time

# Llama 모델 요청 엔드포인트
@app.post("/predict/")
async def predict(request: LlamaRequest):
    try:
        response, response_time = run_llama_model(tokenizer, model, device, request.user_input)
        return {"response": response, "response_time": response_time}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
