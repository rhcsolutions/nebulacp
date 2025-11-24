import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'nestjs-prisma';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

@Injectable()
export class DomainsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.domain.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string, userId: string) {
    const domain = await this.prisma.domain.findUnique({
      where: { id },
    });

    if (!domain || domain.userId !== userId) {
      throw new NotFoundException('Domain not found');
    }

    return domain;
  }

  async create(dto: { domain: string; phpVersion?: string }, userId: string) {
    const user = await this.prisma.account.findUnique({
      where: { id: userId },
    });

    const path = `/home/${user.username}/web/${dto.domain}`;

    // Create domain in database
    const domain = await this.prisma.domain.create({
      data: {
        domain: dto.domain,
        userId,
        path,
        phpVersion: dto.phpVersion || '8.3',
      },
    });

    // TODO: Create actual directory structure and configure web server
    // This would be done by calling system scripts

    return domain;
  }

  async enableSsl(id: string, userId: string) {
    const domain = await this.findOne(id, userId);

    // TODO: Call Caddy/certbot to enable SSL
    // For now, just update the database
    return this.prisma.domain.update({
      where: { id },
      data: {
        sslEnabled: true,
        sslExpires: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000), // 90 days
      },
    });
  }

  async remove(id: string, userId: string) {
    const domain = await this.findOne(id, userId);

    // TODO: Remove directory and web server config
    
    await this.prisma.domain.delete({
      where: { id },
    });

    return { message: 'Domain deleted successfully' };
  }
}
