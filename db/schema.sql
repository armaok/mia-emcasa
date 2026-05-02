CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS humanos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome TEXT NOT NULL,
  telefone TEXT UNIQUE NOT NULL,
  email TEXT,
  notas TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS locais (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  endereco TEXT NOT NULL,
  complemento TEXT,
  bairro TEXT,
  cidade TEXT DEFAULT 'Londrina',
  estado TEXT DEFAULT 'PR',
  notas TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS animais (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome TEXT NOT NULL,
  especie TEXT NOT NULL,
  raca TEXT,
  sexo TEXT,
  idade_anos INTEGER,
  idade_meses INTEGER,
  castrado BOOLEAN,
  cor TEXT,
  notas TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS casos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  humano_id UUID NOT NULL REFERENCES humanos(id),
  animal_id UUID NOT NULL REFERENCES animais(id),
  local_id UUID NOT NULL REFERENCES locais(id),
  telegram_channel_id TEXT,
  telegram_channel_nome TEXT,
  status TEXT DEFAULT 'ativo',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS conversas_mia (
  phone TEXT PRIMARY KEY,
  historico TEXT,
  last_message TEXT,
  last_message_at TIMESTAMP,
  last_message_id TEXT,
  caso_id UUID REFERENCES casos(id),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prontuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caso_id UUID NOT NULL REFERENCES casos(id),
  data_consulta TIMESTAMP NOT NULL,
  motivo TEXT,
  anamnese TEXT,
  exame_fisico TEXT,
  diagnostico TEXT,
  plano TEXT,
  observacoes TEXT,
  status TEXT DEFAULT 'rascunho',
  pdf_url TEXT,
  assinado_em TIMESTAMP,
  embedding vector(1536),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prescricoes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caso_id UUID NOT NULL REFERENCES casos(id),
  prontuario_id UUID REFERENCES prontuarios(id),
  data_prescricao TIMESTAMP NOT NULL,
  medicamentos TEXT NOT NULL,
  status TEXT DEFAULT 'rascunho',
  pdf_url TEXT,
  assinado_em TIMESTAMP,
  enviado_tutor_em TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS documentos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caso_id UUID NOT NULL REFERENCES casos(id),
  tipo TEXT NOT NULL,
  nome TEXT NOT NULL,
  drive_url TEXT NOT NULL,
  mime_type TEXT,
  tamanho_bytes INTEGER,
  embedding vector(1536),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS financeiro (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caso_id UUID NOT NULL REFERENCES casos(id),
  tipo TEXT NOT NULL,
  descricao TEXT,
  valor DECIMAL(10,2) NOT NULL,
  forma_pagamento TEXT,
  status TEXT DEFAULT 'pendente',
  nota_fiscal_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS correcoes_mia (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  contexto TEXT,
  incorporado BOOLEAN DEFAULT FALSE,
  incorporado_em TIMESTAMP,
  versao_prompt TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mia_decisions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caso_id UUID REFERENCES casos(id),
  tipo TEXT NOT NULL,
  input TEXT,
  output TEXT,
  modelo TEXT,
  tokens_input INTEGER,
  tokens_output INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_humanos_telefone ON humanos(telefone);
CREATE INDEX IF NOT EXISTS idx_casos_humano ON casos(humano_id);
CREATE INDEX IF NOT EXISTS idx_casos_animal ON casos(animal_id);
CREATE INDEX IF NOT EXISTS idx_casos_telegram ON casos(telegram_channel_id);
CREATE INDEX IF NOT EXISTS idx_prontuarios_caso ON prontuarios(caso_id);
CREATE INDEX IF NOT EXISTS idx_prescricoes_caso ON prescricoes(caso_id);
CREATE INDEX IF NOT EXISTS idx_documentos_caso ON documentos(caso_id);
CREATE INDEX IF NOT EXISTS idx_financeiro_caso ON financeiro(caso_id);
CREATE INDEX IF NOT EXISTS idx_correcoes_incorporado ON correcoes_mia(incorporado);
CREATE INDEX IF NOT EXISTS idx_mia_decisions_caso ON mia_decisions(caso_id);
CREATE INDEX IF NOT EXISTS idx_prontuarios_embedding ON prontuarios USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_documentos_embedding ON documentos USING ivfflat (embedding vector_cosine_ops);
