# Stage 1: Build Next.js Frontend
FROM node:18 AS frontend-builder
WORKDIR /app/frontend
COPY health-report-upload/ ./
RUN npm install && npm run build

# Stage 2: Set up Python Backend
FROM python:3.9 AS backend
WORKDIR /app/backend
COPY health-report-backend/ ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the built frontend into the backend
COPY --from=frontend-builder /app/frontend/.next /app/backend/frontend-build
COPY --from=frontend-builder /app/frontend/public /app/backend/frontend-build/public

# Expose ports
EXPOSE 5000 3000

# Start Backend and Serve Frontend
CMD ["sh", "-c", "gunicorn -b 0.0.0.0:5000 final-code:app & npx serve -s /app/backend/frontend-build -l 3000"]
