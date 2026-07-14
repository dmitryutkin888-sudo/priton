FROM golang:1.22-alpine
WORKDIR /app
COPY go.mod ./
COPY . ./
RUN go build -o /priton-api ./cmd/api
EXPOSE 8080
CMD ["/priton-api"]
