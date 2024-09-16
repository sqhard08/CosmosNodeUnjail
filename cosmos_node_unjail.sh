1#!/bin/bash

# Путь к лог-файлу
LOG_FILE="/root/jail_arkeo_testnet.log"

# Загрузка конфигурационного файла
source /path/to/config.sh

# Функция для записи в лог
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" > /dev/null
}

# Проверка статуса jailed
jailed_status=$(curl -s "https://arkeo-testnet.api.stakevillage.net/cosmos/staking/v1beta1/validators/tarkeovaloper18ad2hjs4792pkqyz2y8ef99cptweyj6r22n0p0" | jq -r .validator.jailed)

log "Статус jailed: $jailed_status"

if [ "$jailed_status" = "false" ]; then
    log "Валидатор Arkeo Testnet не в тюрьме. Завершение скрипта."
    exit 0
fi

# Отправка сообщения в Telegram
initial_message="Валидатор Arkeo Testnet в тюрьме. Начинаем процесс вывода."

send_telegram_message "$initial_message"
log "Отправлено сообщение в Telegram"

# Функция для проверки разницы высот и выполнения команды unjail
check_heights_and_unjail() {
    while true; do
        # Получение высоты блока из API StakeVillage
        api_height=$(curl -s "https://arkeo-testnet.api.stakevillage.net/cosmos/base/tendermint/v1beta1/blocks/latest" | jq -r ".block.header.height")

        # Получение высоты блока локальной ноды
        local_height=$(arkeod status 2>&1 | jq -r .SyncInfo.latest_block_height)

        log "Высота блока API: $api_height"
        log "Высота блока локальной ноды: $local_height"

        # Проверка разницы высот
        if [ -n "$api_height" ] && [ -n "$local_height" ]; then
            difference=$((api_height - local_height))
            log "Разница высот: $difference"

            if [ $difference -le 20 ] && [ $difference -ge 0 ]; then
                log "Высота блока в пределах допустимого диапазона. Выполняем команду unjail."
                unjail_result=$(arkeod tx slashing unjail --from wallet --chain-id arkeo --gas-prices 0.01uarkeo --gas-adjustment 1.5 --gas auto -y 2>&1)
                log "Результат выполнения команды unjail: $unjail_result"

                # Задержка 10 секунд перед проверкой статуса
                sleep 10

                # Проверка статуса jailed снова
                new_jailed_status=$(curl -s "https://arkeo-testnet.api.stakevillage.net/cosmos/staking/v1beta1/validators/tarkeovaloper18ad2hjs4792pkqyz2y8ef99cptweyj6r22n0p0" | jq -r .validator.jailed)
                log "Новый статус jailed ноды Arkeo Testnet: $new_jailed_status"

                # Отправка сообщения о результате выполнения и новом статусе в Telegram
                final_message="Выполнена команда unjail для ноды Arkeo Testnet. Результат: $unjail_result\nНовый статус jailed: $new_jailed_status"
                send_telegram_message "$final_message"
                break
            else
                log "Высота блока вне допустимого диапазона. Повторная проверка через 5 минут."
                sleep 300
            fi
        else
            log "Ошибка: Не удалось получить высоту блока"
            send_telegram_message "Ошибка: Не удалось получить высоту блока"
            sleep 300
        fi
    done
}

check_heights_and_unjail
