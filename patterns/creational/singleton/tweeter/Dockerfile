# Usamos Apache como servidor
FROM httpd:latest

# Copiamos los archivos que generaste de Flutter a la carpeta de Apache
COPY build/web/ /usr/local/apache2/htdocs/

# Exponemos el puerto 80
EXPOSE 80
