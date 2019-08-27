FROM openjdk:7

WORKDIR /var/www

RUN git clone https://github.com/RealTimeWeb/blockpy.git
RUN git clone https://github.com/RealTimeWeb/blockly.git

# Install Closure
RUN wget --quiet https://github.com/google/closure-library/zipball/master -O closure.zip
RUN unzip -qq closure.zip
RUN mkdir -p closure-library
RUN mv -f google*/* closure-library

# Build Blockly
RUN mkdir -p /var/www/blockly
WORKDIR /var/www/blockly
RUN cp msg/js/en.js ../en.js
RUN python build.py
RUN cp ../en.js msg/js/en.js

# Build skulpt
WORKDIR /var/www
RUN git clone https://github.com/RealTimeWeb/skulpt.git
RUN apt-get update
RUN apt-get install -y python3
RUN cd skulpt && python3 skulpt.py dist

# Build Blockpy
RUN mkdir -p /var/www/blockpy/
WORKDIR /var/www/blockpy/
RUN python build.py
RUN cp /var/www/blockpy/blockpy_new.html /var/www/blockpy/index.html

# Install Nginx
#RUN apt-get install -y software-properties-common
RUN \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/www

COPY ./nginx.conf /etc/nginx/sites-enabled/default

EXPOSE 80

CMD ["nginx"]
