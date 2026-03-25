.PHONY: lint breaking generate

lint:
	buf lint

breaking:
	buf breaking --against '.git#branch=main'

generate:
	buf generate
