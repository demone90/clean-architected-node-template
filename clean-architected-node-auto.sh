#!/bin/bash

# Exit script on error
set -e

# Define project name
PROJECT_NAME=""

# Create project directory
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express body-parser class-transformer class-validator dotenv module-alias

# Install development dependencies
npm install --save-dev @types/express @types/node ts-node typescript

# Generate tsconfig.json
npx tsc --init --rootDir src --outDir dist --esModuleInterop --resolveJsonModule --lib es6,dom --module commonjs

# Correctly update compilerOptions in tsconfig.json
jq '.compilerOptions |= . + {
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true
  }' tsconfig.json > temp_tsconfig.json && mv temp_tsconfig.json tsconfig.json

# Create basic project structure
mkdir -p src/{application/use_cases,domain/{entities,repositories},infrastructure/repositories,interface_adapters/controllers}

# Create a simple Express server as an example
cat <<EOT >> src/interface_adapters/app.ts
import express from 'express';
require('module-alias/register');

const app = express();

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});
EOT

# Add scripts to package.json
jq '.scripts += {
  "build": "tsc",
  "build:watch": "tsc -w",
  "start": "node -r module-alias/register dist/interface_adapters/app.js"
}' package.json > temp.json && mv temp.json package.json

echo "Add additional info for paths and rootdir in tsconfig.json for easier imports"
echo "Setup complete. Run 'npm run start' to start the application."

