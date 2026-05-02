CREATE TABLE IF NOT EXISTS conversas_telegram (
  chat_id TEXT PRIMARY KEY,
  historico TEXT,
  last_message TEXT,
  last_message_at TIMESTAMP,
  caso_id UUID REFERENCES casos(id),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_conversas_telegram_chat 
  ON conversas_telegram(chat_id);
