FROM python:3.11.3-alpine3.18
LABEL maintainer="cleusiopinto997@gmail.com"

# Variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Copia a pasta "djangoapp" e "scripts" para dentro do container
COPY djangoapp /djangoapp
COPY scripts /scripts

WORKDIR /djangoapp

EXPOSE 8000

# 1. Instala dependências do sistema necessárias para compilar pacotes no Alpine (ex: psycopg2)
# 2. Cria o ambiente virtual e instala os pacotes
# 3. Cria o usuário e ajusta permissões
RUN apk update && \
    apk add --no-cache \
        postgresql-client \
        netcat-openbsd \
        build-base \
        postgresql-dev \
        musl-dev && \
    python -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install -r /djangoapp/requirements.txt && \
    apk del build-base && \
    adduser --disabled-password --no-create-home duser && \
    mkdir -p /data/web/static && \
    mkdir -p /data/web/media && \
    chown -R duser:duser /venv && \
    chown -R duser:duser /data/web/static && \
    chown -R duser:duser /data/web/media && \
    chmod -R 755 /data/web/static && \
    chmod -R 755 /data/web/media && \
    chmod -R +x /scripts

# Adiciona a pasta scripts e venv/bin ao $PATH do container
ENV PATH="/scripts:/venv/bin:$PATH"

# Muda o usuário para duser
USER duser

# Executa o arquivo scripts/commands.sh
CMD ["commands.sh"]