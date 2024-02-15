# Dockerfile
FROM nginx:latest

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy a new configuration file from the current directory
COPY nginx.conf /etc/nginx/conf.d

# Copy a basic HTML file to the html directory
COPY index.html /usr/share/nginx/html/index.html
COPY access.html /usr/share/nginx/html/access.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
