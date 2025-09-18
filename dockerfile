# Stage 1: Build stage
FROM node:22.12.0 AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (or yarn.lock/pnpm-lock.yaml)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the app source code
COPY . .

# Build the NestJS app
RUN npm run build

# Stage 2: Runtime for AWS Lambda
FROM public.ecr.aws/lambda/nodejs:22

# Set working directory inside Lambda
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy package.json (only production dependencies)
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy compiled dist from builder
COPY --from=builder /usr/src/app/dist ./dist

# Lambda will look for handler function here
# Adjust "main.handler" to match your compiled NestJS entrypoint
CMD ["dist/main.handler"]
