import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class AlertService {
  constructor(private config: ConfigService) {}

  async loginAlert(username: string, ip: string) {
    const message = `🔐 New login: ${username} from ${ip}`;
    await Promise.all([
      this.sendTelegram(message),
      this.sendSlack(message),
    ]);
  }

  async backupFailed(domain: string, error: string) {
    const message = `❌ Backup failed for ${domain}: ${error}`;
    await Promise.all([
      this.sendTelegram(message),
      this.sendSlack(message),
    ]);
  }

  async highLoad(cpu: number, ram: number) {
    const message = `⚠️ High system load: CPU ${cpu}% | RAM ${ram}%`;
    await Promise.all([
      this.sendTelegram(message),
      this.sendSlack(message),
    ]);
  }

  private async sendTelegram(message: string) {
    const token = this.config.get('telegram.botToken');
    const chatId = this.config.get('telegram.chatId');

    if (!token || !chatId) return;

    try {
      await axios.post(`https://api.telegram.org/bot${token}/sendMessage`, {
        chat_id: chatId,
        text: message,
        parse_mode: 'HTML',
      });
    } catch (error) {
      console.error('Telegram error:', error.message);
    }
  }

  private async sendSlack(message: string) {
    const webhookUrl = this.config.get('slack.webhookUrl');

    if (!webhookUrl) return;

    try {
      await axios.post(webhookUrl, { text: message });
    } catch (error) {
      console.error('Slack error:', error.message);
    }
  }
}
