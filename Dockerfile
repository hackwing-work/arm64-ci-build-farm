# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS build
ARG TARGETOS TARGETARCH VERSION=dev COMMIT=none BUILD_DATE=unknown
WORKDIR /src
COPY go.mod ./
COPY cmd ./cmd
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
    -trimpath \
    -ldflags="-s -w -X main.version=$VERSION -X main.commit=$COMMIT -X main.builtAt=$BUILD_DATE" \
    -o /out/build-info ./cmd/build-info

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/build-info /build-info
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/build-info"]

