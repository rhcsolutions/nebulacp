export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    url: process.env.DATABASE_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  frontend: {
    url: process.env.FRONTEND_URL || 'http://localhost:3001',
  },
  ollama: {
    url: process.env.OLLAMA_URL || 'http://127.0.0.1:11434',
  },
  comfyui: {
    url: process.env.COMFYUI_URL || 'http://127.0.0.1:8188',
  },
  telegram: {
    botToken: process.env.TELEGRAM_BOT_TOKEN,
    chatId: process.env.TELEGRAM_CHAT_ID,
  },
  slack: {
    webhookUrl: process.env.SLACK_WEBHOOK_URL,
  },
});
