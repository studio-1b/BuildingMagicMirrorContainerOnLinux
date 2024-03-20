FROM node:latest

# Change the working directory on the Docker image to /app
WORKDIR /app

# Copy package.json and package-lock.json to the /app directory
#COPY package.json package-lock.json ./
RUN git clone https://github.com/MagicMirrorOrg/MagicMirror.git
WORKDIR /app/MagicMirror

# Create volume to configuration
RUN mkdir logs
VOLUME /app/logs

# run MM installer
RUN npm run install-mm

# Install modules
# Add below

# Start module add section
# WORKDIR /app/MagicMirror/modules
# RUN git clone <github address of module>
# WORKDIR /app/MagicMirror/modules/<folder git creates above>
# RUN npm install

# Copy the rest of project files into this image
COPY config.js /app/MagicMirror/config

# Expose application port
EXPOSE 3000

# Start the application
WORKDIR /app/MagicMirror
CMD npm run server

