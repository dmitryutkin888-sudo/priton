FROM golang:1.22-alpine
WORKDIR /app
COPY go.mod ./
COPY backend ./backend
COPY web ./web
RUN go build -o /priton-api ./backend/cmd/api
EXPOSE 8080
CMD ["/priton-api"]
