FROM eclipse-temurin:17-jdk-jammy

# Install base tools, repo keys, and Maven
RUN apt-get update && apt-get install -y wget gnupg maven \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

## Install Google Chrome AND the mandatory missing Linux libraries (Fixes Exit 127)
RUN apt-get update && apt-get install -y \
    google-chrome-stable \
    libglib2.0-0 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tests
COPY pom.xml .   
# Remove -q so you can see if dependencies download correctly
RUN mvn dependency:go-offline dependency:resolve-plugins
COPY src ./src
# Removed -q and added property to force immediate log flushes
CMD ["mvn", "test", "-Dsurefire.skipAfterFailureCount=0", "-Dorg.slf4j.simpleLogger.defaultLogLevel=info"]

