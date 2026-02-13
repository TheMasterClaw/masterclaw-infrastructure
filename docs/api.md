# API Documentation

## Base URL

```
Production:  https://api.yourdomain.com
Development: http://localhost:3001
```

## Authentication

Most endpoints require an API key:
```bash
Authorization: Bearer YOUR_API_KEY
```

## Endpoints

### Health

#### GET /health
Check service health.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-02-13T10:45:00Z",
  "version": "0.1.0",
  "services": {
    "memory": "chroma",
    "llm_providers": ["openai", "anthropic"]
  }
}
```

### Chat

#### POST /v1/chat
Send a message and get AI response.

**Request:**
```json
{
  "message": "Hello MasterClaw!",
  "session_id": "abc123",
  "provider": "openai",
  "model": "gpt-4",
  "temperature": 0.7,
  "use_memory": true
}
```

**Response:**
```json
{
  "response": "Hello Rex! How can I help you today?",
  "model": "gpt-4",
  "provider": "openai",
  "session_id": "abc123",
  "tokens_used": 25,
  "memories_used": 3,
  "timestamp": "2026-02-13T10:45:01Z"
}
```

### Memory

#### POST /v1/memory/search
Search memories using semantic similarity.

**Request:**
```json
{
  "query": "backup strategy",
  "top_k": 5,
  "filter_metadata": {
    "category": "infrastructure"
  }
}
```

**Response:**
```json
{
  "query": "backup strategy",
  "results": [
    {
      "id": "mem_123",
      "content": "Daily backups at 2 AM",
      "metadata": {"category": "infrastructure"},
      "timestamp": "2026-02-13T02:00:00Z"
    }
  ],
  "total_results": 1
}
```

#### POST /v1/memory/add
Add a new memory.

**Request:**
```json
{
  "content": "Remember to update SSL certificates",
  "metadata": {"priority": "high"},
  "source": "user_instruction"
}
```

**Response:**
```json
{
  "success": true,
  "memory_id": "mem_456",
  "message": "Memory added successfully"
}
```

#### GET /v1/memory/{id}
Get a specific memory.

**Response:**
```json
{
  "id": "mem_123",
  "content": "Daily backups at 2 AM",
  "metadata": {"category": "infrastructure"},
  "timestamp": "2026-02-13T02:00:00Z"
}
```

#### DELETE /v1/memory/{id}
Delete a memory.

**Response:**
```json
{
  "success": true,
  "message": "Memory deleted successfully"
}
```

### Tasks

#### GET /tasks
List all tasks.

**Query Parameters:**
- `status` - Filter by status (open, in_progress, done)
- `priority` - Filter by priority (low, normal, high)

**Response:**
```json
[
  {
    "id": "task_123",
    "title": "Deploy to production",
    "status": "in_progress",
    "priority": "high",
    "created_at": "2026-02-13T10:00:00Z"
  }
]
```

#### POST /tasks
Create a new task.

**Request:**
```json
{
  "title": "Update documentation",
  "description": "Add API examples",
  "priority": "normal",
  "dueDate": "2026-02-14"
}
```

#### PATCH /tasks/{id}
Update a task.

**Request:**
```json
{
  "status": "done",
  "priority": "high"
}
```

#### DELETE /tasks/{id}
Delete a task.

### Calendar

#### GET /calendar/events
List all events.

#### POST /calendar/events
Create a new event.

**Request:**
```json
{
  "title": "Team Meeting",
  "startTime": "2026-02-14T10:00:00Z",
  "endTime": "2026-02-14T11:00:00Z",
  "description": "Weekly sync"
}
```

### WebSocket

#### WS /ws/{session_id}
Real-time communication.

**Connection:**
```javascript
const ws = new WebSocket('ws://localhost:8000/ws/session_123');
```

**Send message:**
```json
{
  "type": "message",
  "content": "Hello!"
}
```

**Receive message:**
```json
{
  "type": "message",
  "role": "assistant",
  "content": "Hello Rex!",
  "timestamp": "2026-02-13T10:45:01Z"
}
```

## Error Codes

| Status | Code | Description |
|--------|------|-------------|
| 400 | BAD_REQUEST | Invalid request |
| 401 | UNAUTHORIZED | Missing/invalid API key |
| 404 | NOT_FOUND | Resource not found |
| 422 | VALIDATION_ERROR | Validation failed |
| 429 | RATE_LIMITED | Too many requests |
| 500 | INTERNAL_ERROR | Server error |
| 503 | SERVICE_UNAVAILABLE | LLM provider error |

## Rate Limits

- 60 requests per minute per IP
- 1000 requests per hour per API key

Headers included in responses:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
```

---

*API v1.0* 🐾
