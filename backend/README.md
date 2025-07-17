# Entrepreneur Journey Backend API

This is a simple Express.js backend server that handles API calls for the Entrepreneur Journey app.

## Features

- RESTful API for managing business ideas
- CRUD operations (Create, Read, Update, Delete)
- In-memory data storage (for development purposes)

## API Endpoints

### Business Ideas

- `GET /v1/ideas` - Get all business ideas
- `GET /v1/ideas/:id` - Get a specific business idea
- `POST /v1/ideas` - Create a new business idea
- `PUT /v1/ideas/:id` - Update an existing business idea
- `DELETE /v1/ideas/:id` - Delete a business idea

## Getting Started

1. Install dependencies:
   ```
   npm install
   ```

2. Start the server:
   ```
   node server.js
   ```

3. The server will run on port 3000 by default (http://localhost:3000)

## Integration with Swift App

Update the `baseURL` in your Swift app's `APIService.swift` file to point to this server:

```swift
private let baseURL = "http://localhost:3000/v1"
```

## Production Considerations

For a production environment, consider:
- Using a real database (MongoDB, PostgreSQL, etc.)
- Adding authentication and authorization
- Implementing environment-specific configuration
- Setting up proper error handling and logging
