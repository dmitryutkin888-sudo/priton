FROM golang:1.22-alpine
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
COPY backend ./backend
COPY web ./web
RUN go build -o /priton-api ./backend/cmd/api
EXPOSE 30385
CMD ["/priton-api"]
