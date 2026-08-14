FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN  npm -g install netlify-cli@17 node-jq serve
