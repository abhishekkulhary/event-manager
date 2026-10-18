# Use the official Flutter base image
FROM ghcr.io/cirruslabs/flutter:stable

# Set the working directory
WORKDIR /app

# Copy the application files
COPY . .

# Get dependencies
RUN flutter pub get

# Run pre-build cleanup
RUN flutter clean

# Enable desktop and web support
RUN flutter config --enable-linux-desktop \
    && flutter config --enable-macos-desktop \
    && flutter config --enable-windows-desktop \
    && flutter config --enable-web

# RUN apt update && apt install -y cmake ninja && rm -rf /var/lib/apt/lists/*

# Build for web
RUN flutter build web

# Build for Windows
# RUN flutter build windows

# Build for macOS
# RUN flutter build macos

# Build for Linux
# RUN flutter build linux

# Build for Android
RUN flutter build apk

# Build for iOS (only on macOS)
# RUN flutter build ios --no-codesign