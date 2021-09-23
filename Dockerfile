FROM node:16-bullseye-slim as build-dependencies-helper

# Install tools
RUN apt-get update && apt-get install -y build-essential python3

# Create app directory
WORKDIR /app

# The current working directory
COPY . . 

# Install dependencies
RUN yarn workspaces focus -A --production

# TS Build Stage
FROM build-dependencies-helper as manager-builder

# Change directory to '/app'
WORKDIR /app

# Install dependencies
RUN yarn install

# Build TS code
RUN yarn build

# Delete everyhing we don't need in the next stage
RUN rm -rf node_modules tsconfig.tsbuildinfo *.ts **/*.ts .eslint* .git* .prettier* .vscode* tsconfig.json .yarn* yarn.lock

# Final image
FROM node:16-bullseye-slim AS manager

# Copy built code from build stage to '/app' directory
COPY --from=manager-builder /app /app

# Copy node_modules
COPY --from=build-dependencies-helper /app/node_modules /app/node_modules

# Change directory to '/app'
WORKDIR /app

EXPOSE 3006
CMD [ "node", "bin/www.mjs" ]
