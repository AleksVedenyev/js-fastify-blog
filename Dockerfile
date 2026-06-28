FROM node:26-slim

RUN apt-get update && apt-get install -y \
    make \
    python3 \
    python3-setuptools \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Указываем рабочую директорию внутри контейнера
WORKDIR /app

# Сначала копируем файлы зависимостей (для эффективного кэширования слоев Docker)
COPY package*.json ./

# Устанавливаем ВСЕ зависимости (включая devDependencies, так как они нужны для билда ассетов)
RUN npm ci --ignore-scripts

# Копируем весь оставшийся исходный код приложения
COPY . .

# Собираем фронтенд-ассеты (компиляция стилей, скриптов и т.д.)
RUN make build

# Удаляем dev-зависимости, чтобы уменьшить размер итогового образа для продакшена
RUN npm prune --production

# Открываем порт, который приложение слушает по умолчанию (из README это 8080)
EXPOSE 8080

# Переменная окружения по умолчанию
ENV NODE_ENV=production

# Команда для запуска приложения в продакшене
CMD ["make", "start"]