test:
	go test -v ./vmx-query-expansion

cover:
	go test -v ./auth  -coverprofile=/tmp/coverage.out
	go tool cover -html=/tmp/coverage.out
