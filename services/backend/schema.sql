-- MasterClaw Database Schema
-- SQLite database for production data

-- Sessions table for tracking user interactions
CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    ended_at DATETIME,
    context TEXT,  -- JSON blob of session context
    mode TEXT DEFAULT 'text',  -- text, voice, hybrid, context
    metadata TEXT  -- JSON blob
);

-- Messages table for chat history
CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT,
    role TEXT CHECK(role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    metadata TEXT,  -- JSON blob (tokens used, model, etc.)
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

-- Memories table for long-term storage
CREATE TABLE IF NOT EXISTS memories (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    embedding BLOB,  -- Vector embedding for similarity search
    category TEXT,
    importance INTEGER DEFAULT 1,  -- 1-5 scale
    source TEXT,  -- Where this memory came from
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    accessed_at DATETIME,  -- Last time this was retrieved
    access_count INTEGER DEFAULT 0,
    metadata TEXT  -- JSON blob
);

-- Create index for memory search
CREATE INDEX IF NOT EXISTS idx_memories_category ON memories(category);
CREATE INDEX IF NOT EXISTS idx_memories_importance ON memories(importance);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'open' CHECK(status IN ('open', 'in_progress', 'done', 'cancelled')),
    priority TEXT DEFAULT 'normal' CHECK(priority IN ('low', 'normal', 'high', 'urgent')),
    due_date DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    tags TEXT,  -- Comma-separated
    assignee TEXT,
    source TEXT,  -- Where task was created
    metadata TEXT
);

-- Calendar events
CREATE TABLE IF NOT EXISTS events (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    location TEXT,
    attendees TEXT,  -- JSON array
    recurrence TEXT,  -- RRULE format
    source TEXT,  -- google, local, etc.
    external_id TEXT,  -- ID from external calendar
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Settings/preferences
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Audit log for important actions
CREATE TABLE IF NOT EXISTS audit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action TEXT NOT NULL,
    actor TEXT,
    target_type TEXT,
    target_id TEXT,
    details TEXT,  -- JSON blob
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT OR IGNORE INTO settings (key, value) VALUES
('theme', 'dark'),
('tts_enabled', 'true'),
('tts_provider', 'openai'),
('notifications_enabled', 'true'),
('auto_backup', 'true'),
('backup_interval_hours', '24'),
('session_timeout_minutes', '60');
