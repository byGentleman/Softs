import time
import requests
import logging
import os

# Константы API
API_ENDPOINT = "https://api.hyperbolic.xyz/v1/chat/completions"
API_KEY = "$API_KEY"  # Здесь должен быть ваш API-ключ
MODEL_NAME = "NousResearch/Hermes-3-Llama-3.1-70B"
TOKEN_LIMIT = 2048
TEMP = 0.7
TOP_PROB = 0.9
PAUSE_DURATION = 25  # Уменьшена задержка между запросами

# Настройки логирования
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("HyperbolicChat")

def get_response(question: str) -> str:
    """Отправляет запрос к API и возвращает ответ"""
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "messages": [{"role": "user", "content": question}],
        "model": MODEL_NAME,
        "max_tokens": TOKEN_LIMIT,
        "temperature": TEMP,
        "top_p": TOP_PROB
    }
    try:
        response = requests.post(API_ENDPOINT, headers=headers, json=payload, timeout=30)
        response.raise_for_status()
        return response.json().get("choices", [{}])[0].get("message", {}).get("content", "No response received")
    except requests.RequestException as err:
        logger.error(f"Ошибка запроса: {err}")
        return "Error fetching response"

def main():
    """Основная логика работы: загрузка вопросов и запрос к API"""
    try:
        with open("questions.txt", encoding="utf-8") as file:
            questions = [line.strip() for line in file if line.strip()]
    except Exception as err:
        logger.error(f"Ошибка чтения файла questions.txt: {err}")
        return

    if not questions:
        logger.error("Файл questions.txt пуст или не найден.")
        return

    index = 0
    while True:
        question = questions[index]
        logger.info(f"Вопрос #{index + 1}: {question}")
        try:
            answer = get_response(question)
            logger.info(f"Ответ: {answer}")
        except Exception as err:
            logger.error(f"Ошибка при получении ответа: {err}")
        index = (index + 1) % len(questions)
        time.sleep(PAUSE_DURATION)

if __name__ == "__main__":
    main()
