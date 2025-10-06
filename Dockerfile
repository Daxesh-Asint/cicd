# Use the official nginx image as base
FROM nginx:alpine

# Copy the HTML file to nginx web directory
COPY index.html /usr/share/nginx/html/

# Copy any additional static assets (CSS, JS, images) if they exist
COPY --chown=nginx:nginx . /usr/share/nginx/html/

# Create a custom nginx configuration for better performance
RUN echo 'server { \
    listen 8080; \
    listen [::]:8080; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Security headers \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
    \
    # Gzip compression \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 1024; \
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json; \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # Cache static assets \
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Remove the default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf.bak 2>/dev/null || true

# Cloud Run expects the container to listen on port 8080
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]