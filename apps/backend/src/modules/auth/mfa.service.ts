import { Injectable } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import * as speakeasy from 'speakeasy';

@Injectable()
export class MfaService {
  constructor(private prisma: PrismaService) {}

  async enableMfa(userId: string) {
    const secret = speakeasy.generateSecret({
      name: 'NebulaCP',
      length: 32,
    });

    await this.prisma.mfa.upsert({
      where: { userId },
      create: {
        userId,
        secret: secret.base32,
        enabled: false,
        backupCodes: this.generateBackupCodes(),
      },
      update: {
        secret: secret.base32,
      },
    });

    return {
      secret: secret.base32,
      qrCode: secret.otpauth_url,
    };
  }

  async verifyMfa(userId: string, token: string) {
    const mfa = await this.prisma.mfa.findUnique({
      where: { userId },
    });

    if (!mfa) {
      return { verified: false };
    }

    const verified = speakeasy.totp.verify({
      secret: mfa.secret,
      encoding: 'base32',
      token,
      window: 2,
    });

    if (verified && !mfa.enabled) {
      await this.prisma.mfa.update({
        where: { userId },
        data: { enabled: true },
      });
    }

    return { verified };
  }

  private generateBackupCodes(): string[] {
    const codes = [];
    for (let i = 0; i < 10; i++) {
      codes.push(Math.random().toString(36).substring(2, 10).toUpperCase());
    }
    return codes;
  }
}
