FROM ruby:2.2.2-onbuild
RUN apt-get -y update
RUN apt-get -y install nodejs
CMD ["dashing", "start", "-p", "4567", "-e", "production", "-t", "90"]
