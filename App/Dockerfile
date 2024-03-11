FROM --platform=linux/amd64 python:3.8-alpine AS build
WORKDIR /app
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY . /app
CMD ["python", "app.py"]