# =========================================================
# Stage 1: Build Stage (Flutter SDK)
# =========================================================
FROM plugfox/flutter:stable AS base

# Create working directory inside container
WORKDIR /app

# Copy dependency configs and get packages
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy full application source code
COPY . .

# Build static release assets for web
RUN flutter build web --release

# =========================================================
# Stage 2: Final Secure Production Stage (Nginx Web Server)
# =========================================================
FROM nginx:alpine

# Copy built static HTML/JS/CSS files from Stage 1 into Nginx default root
COPY --from=base /app/build/web /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]