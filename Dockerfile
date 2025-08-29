FROM mcr.microsoft.com/playwright:v1.55.0-jammy
RUN npm install netlify-cli@20.1.1 -g node-jq -g serve -g
