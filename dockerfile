# Use nginx as the base image
   FROM nginx:latest

   # Update package lists and install nginx
   RUN apt-get update \
       && apt-get install -y nginx

   # Create a custom index page
   COPY index.html /usr/share/nginx/html/index.html

   # CMD to start nginx and keep the container running
   CMD ["nginx", "-g", "daemon off;"]