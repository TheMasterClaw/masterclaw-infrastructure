# Contributing to MasterClaw

Thank you for your interest in contributing! 🐾

## Getting Started

1. **Fork** the repository
2. **Clone** your fork
3. **Create a branch** for your feature
4. **Make changes** with clear commits
5. **Test** thoroughly
6. **Submit a PR** with description

## Development Setup

```bash
# Clone all repos
for repo in masterclaw-infrastructure masterclaw-core masterclaw-tools rex-deus level100-studios; do
  git clone https://github.com/TheMasterClaw/$repo.git
done

# Start development environment
cd masterclaw-infrastructure
make dev

# Install CLI locally
cd ../masterclaw-tools
npm link
```

## Code Standards

### Python (Core)
- Follow PEP 8
- Use type hints
- Write docstrings
- Add tests for new features

```python
def process_message(message: str) -> dict:
    """Process incoming message.
    
    Args:
        message: The message to process
        
    Returns:
        Processed message data
    """
    return {"processed": message}
```

### JavaScript (Tools/Interface)
- Use ES6+ features
- Async/await for async code
- JSDoc for functions
- ESLint for linting

```javascript
/**
 * Process incoming message
 * @param {string} message - Message to process
 * @returns {Promise<object>} Processed data
 */
async function processMessage(message) {
  return { processed: message };
}
```

### Commits

Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `refactor`: Code refactoring
- `chore`: Maintenance

Example:
```
feat(core): add WebSocket support for real-time chat

- Implement ConnectionManager for session handling
- Add ping/pong keepalive
- Broadcast messages to session members

Closes #123
```

## Testing

### Running Tests

```bash
# Core tests
cd masterclaw-core
pytest

# Tools tests
cd masterclaw-tools
npm test

# Integration tests
cd masterclaw-infrastructure
make test
```

### Writing Tests

**Python:**
```python
def test_chat_endpoint():
    response = client.post("/v1/chat", json={
        "message": "Hello"
    })
    assert response.status_code == 200
    assert "response" in response.json()
```

**JavaScript:**
```javascript
test('chat command exists', () => {
  expect(commands).toHaveProperty('chat');
});
```

## Pull Request Process

1. Update documentation for new features
2. Add tests for bug fixes
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers

## Areas for Contribution

### High Priority
- [ ] More LLM providers (Claude, local models)
- [ ] Better memory retrieval algorithms
- [ ] Mobile app improvements
- [ ] Voice synthesis integration
- [ ] Enhanced security features

### Documentation
- [ ] API examples
- [ ] Tutorial videos
- [ ] Deployment guides
- [ ] Architecture diagrams

### Testing
- [ ] Integration tests
- [ ] Load testing
- [ ] Security audits
- [ ] Browser compatibility

## Code Review

PRs will be reviewed for:
- **Functionality** - Does it work?
- **Code quality** - Is it maintainable?
- **Tests** - Are there adequate tests?
- **Documentation** - Is it documented?
- **Style** - Does it follow conventions?

## Questions?

- Open an issue for bugs
- Start a discussion for features
- Join Discord for chat (coming soon)

---

*Build with intention.* 🐾
