#!/bin/bash

echo "Используйте образ Ubuntu 22.04"

# Убедитесь, что вы запускаете скрипт с правами суперпользователя
if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите скрипт с правами суперпользователя"
    exit 1
fi

if command -v docker > /dev/null 2>&1; then
    echo "Docker установлен."
else
    echo "Устанавливаем Docker "
############
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
################
fi

# Параметры
REPO_URL="https://github.com/vakhtanov/shvirtd-dz5_vah.git"
TARGET_DIR="/opt/shvirtd-dz5_vah"

# Скачивание репозитория
if [ ! -d "$TARGET_DIR" ]; then
    echo "Скачивание репозитория..."
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo "Репозиторий уже существует в $TARGET_DIR. Обновляем..."
    cd "$TARGET_DIR"
    git pull origin main  # или master, в зависимости от основной ветки
fi

# Переход в каталог проекта
cd "$TARGET_DIR" || exit

# Запуск проекта с помощью Docker Compose
if [ -f "compose.yaml" ]; then
    echo "Запуск проекта с помощью Docker Compose..."
    docker compose up -d
else
    echo "Файл compose.yaml не найден в $TARGET_DIR. Убедитесь, что вы находитесь в правильном репозитории."
    exit 1
fi

echo "Проект успешно запущен."
echo "Для завершения проекта введите комманду 'docker compose down'"