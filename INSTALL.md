# Mac OSX

# First make sure that go is installed:
```bash
brew reinstall go --with-cc-all
mkdir $HOME/.go
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
```

# Clone (not download) the repository:
```
mkdir -p $HOME/.go/src/github.com/bippar/kube-vproxy-middlewares
git clone https://lucmichalski@bitbucket.org/layardev/kube-vproxy-middlewares.git
cd $HOME/.go/src/github.com/bippar/kube-vproxy-middlewares
cd vmx-query-expansion
go get
go build -o vmx-vproxy .
```

# Install vegeta for bench tests

![Vegeta](http://fc09.deviantart.net/fs49/i/2009/198/c/c/ssj2_vegeta_by_trunks24.jpg)

## Install
### Pre-compiled executables
Get them [here](http://github.com/tsenart/vegeta/releases).

### Homebrew on Mac OS X
You can install Vegeta using the [Homebrew](https://github.com/Homebrew/homebrew/) package manager on Mac OS X:
```shell
$ brew update && brew install vegeta
```

### Source (preferred as we need to implement custom benchmarking tests for transversal batch requests)
You need go installed and `GOBIN` in your `PATH`. Once that is done, run the
command:
```shell
$ go get github.com/tsenart/vegeta
$ go install github.com/tsenart/vegeta
```

# Run vegeta
```shell
cd scripts
chmod +x bench.sh
./bench.sh
```
