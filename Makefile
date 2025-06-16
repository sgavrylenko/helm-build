build:
	@go build -o bin/ticker .

run: build
	@bin/ticker
