#!/bin/bash

# Проверка наличия необходимых утилит, установка если отсутствует
if ! command -v figlet &> /dev/null; then
    echo "figlet не найден. Устанавливаем..."
    sudo apt update && sudo apt install -y figlet
fi

if ! command -v whiptail &> /dev/null; then
    echo "whiptail не найден. Устанавливаем..."
    sudo apt update && sudo apt install -y whiptail
fi

# Определяем цвета
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
BLINK_GREEN="\e[5;32m"
NC="\e[0m"

# Вывод приветственного текста
echo -e "${PINK}$(figlet -w 150 -f standard "Softs by The Gentleman")${NC}"

echo "================================================================="
echo "Добро пожаловать! Подпишись на мой Telegram-канал: https://t.me/GentleChron"
echo "================================================================="
echo ""

# Функция анимации
animate_loading() {
    for ((i = 1; i <= 5; i++)); do
        printf "\r${GREEN}Подгружаем меню${NC}."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}.."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}..."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}"
        sleep 0.3
    done
    echo ""
}

animate_loading
echo ""

# Вывод меню
CHOICE=$(whiptail --title "Меню действий" \
    --menu "Выберите действие:" 18 60 6 \
    "1" "Установить бота" \
    "2" "Обновить бота" \
    "3" "Проверка работы бота" \
    "4" "Перезапустить бота" \
    "5" "Удалить бота" \
    "6" "Вписать свои вопросы" \
    3>&1 1>&2 2>&3)

case $CHOICE in
    1)
        echo -e "${BLUE}Установка бота...${NC}"
        # Установка и настройка
        ;;

    2)
        echo -e "${BLUE}Обновление бота...${NC}"
        sleep 2
        echo -e "${GREEN}Обновление бота пока не требуется!${NC}"
        ;;

    3)
        echo -e "${BLUE}Просмотр логов...${NC}"
        sudo journalctl -u hyper-bot.service -f
        ;;

    4)
        echo -e "${BLUE}Рестарт бота...${NC}"
        sudo systemctl restart hyper-bot.service
        sudo journalctl -u hyper-bot.service -f
        ;;
        
    5)
        echo -e "${BLUE}Удаление бота...${NC}"
        sudo systemctl stop hyper-bot.service
        sudo systemctl disable hyper-bot.service
        sudo rm /etc/systemd/system/hyper-bot.service
        sudo systemctl daemon-reload
        sleep 2
        rm -rf "$HOME/hyperbolic"
        echo -e "${GREEN}Бот успешно удален!${NC}"
        sleep 1
        ;;
    
    6)
        echo -e "${BLUE}Добавление вопросов...${NC}"
        sudo systemctl stop hyper-bot.service
        sleep 2
        QUESTIONS_FILE="$HOME/hyperbolic/questions.txt"

        echo -e "${YELLOW}Данное действие полностью очищает файл с вопросами и заменяет на ваши. Их вводить можно партиями. Скрипт начнёт работать после нажатия комбинации CTRL + D, до этого можете вводить вопросы: 1 строка - вопрос.${NC}"
        sleep 15

        > "$QUESTIONS_FILE"
        
        echo -e "${YELLOW}Можете вставлять вопросы (1 строка — 1 вопрос)${NC}"
        echo -e "${BLINK_GREEN}После воода вопросов, нажмите Ctrl+D:${NC}"
        
        cat > "$QUESTIONS_FILE"
        
        sudo systemctl restart hyper-bot.service
        sudo journalctl -u hyper-bot.service -f
        ;;
    
    *)
        echo -e "${RED}Неверный выбор. Завершение программы.${NC}"
        ;;
esac
