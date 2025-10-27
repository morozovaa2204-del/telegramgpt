import telebot
from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_KEY")
TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")

if not OPENAI_API_KEY or not TELEGRAM_TOKEN:
    raise ValueError("❌ Ошибка: не найдены TELEGRAM_TOKEN или OPENAI_KEY в .env")

bot = telebot.TeleBot(TELEGRAM_TOKEN)
client = OpenAI(api_key=OPENAI_API_KEY)

user_free_used = {}

@bot.message_handler(commands=["start", "help"])
def start_message(message):
    bot.reply_to(
        message,
        "👋 Привет! Отправь мне фото для обработки ✨\n\n"
        "Первая обработка — БЕСПЛАТНО 💫"
    )

@bot.message_handler(content_types=["photo"])
def handle_photo(message):
    user_id = message.from_user.id

    if user_free_used.get(user_id, False):
        bot.reply_to(message, "💳 Ваша бесплатная обработка уже использована.\nХотите оформить подписку? 😊")
        return

    bot.reply_to(message, "📸 Обрабатываю фото... Подожди немного ⏳")

    try:
        file_info = bot.get_file(message.photo[-1].file_id)
        downloaded_file = bot.download_file(file_info.file_path)

        with open("input.jpg", "wb") as f:
            f.write(downloaded_file)

        bot.send_message(message.chat.id, "✅ Фото успешно обработано!")

        user_free_used[user_id] = True

    except Exception as e:
        bot.reply_to(message, f"❌ Ошибка при обработке: {e}")

print("✅ Бот запущен и готов к работе!")
bot.polling(none_stop=True)
