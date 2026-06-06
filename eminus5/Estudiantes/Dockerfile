FROM httpd:latest

COPY build/web/ /usr/local/apache2/htdocs/

# Redirige el tráfico virtual a Flutter
RUN echo "FallbackResource /index.html" >> /usr/local/apache2/conf/httpd.conf

EXPOSE 80