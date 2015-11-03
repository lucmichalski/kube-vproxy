FROM alpine

RUN apk --update add go git \
  && ORG_PATH="github.com/blippar/" \
  && REPO_PATH="${ORG_PATH}kube-vproxy" \
  && export GOPATH=/gopath \
  && export PATH=$PATH:$GOPATH/bin \
  && mkdir -p $GOPATH/src/${ORG_PATH} \
  && ln -s ${PWD} $GOPATH/src/${REPO_PATH} \
  && cd $GOPATH/src/${REPO_PATH} \
  && go get github.com/vulcand/vulcand \
#  && go get github.com/Financial-Times/vulcan-session-auth/sauth \
  && go get github.com/vulcand/vulcand/vbundle \
  && go get github.com/mailgun/log \
#  && vbundle init --middleware=github.com/Financial-Times/vulcan-session-auth/sauth \
  && go build -o kube-vproxy \
  && apk del go git \
  && rm -rf /var/cache/apk/*

CMD /kube-vproxy
