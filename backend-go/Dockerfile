# --- Build stage ---
FROM golang:1.27-alpine AS build
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go tool templ generate \
 && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server \
 && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/goose github.com/pressly/goose/v3/cmd/goose

# --- Runtime stage ---
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /out/server /app/server
COPY --from=build /out/goose /app/goose
COPY migrations /app/migrations
COPY static /app/static

ENV APP_ENV=production PORT=8080
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/app/server"]
