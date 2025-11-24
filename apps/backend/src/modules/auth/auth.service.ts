import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from 'nestjs-prisma';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async login(dto: { email: string; password: string }) {
    const user = await this.prisma.account.findUnique({
      where: { email: dto.email },
      include: { profile: true },
    });

    if (!user || !await bcrypt.compare(dto.password, user.passwordHash)) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account is disabled');
    }

    const payload = { sub: user.id, email: user.email, role: user.role };
    const accessToken = this.jwtService.sign(payload);

    // Create session
    await this.prisma.session.create({
      data: {
        userId: user.id,
        token: accessToken,
        ip: '0.0.0.0', // TODO: Get from request
        userAgent: 'Unknown', // TODO: Get from request
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    return {
      accessToken,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        role: user.role,
        profile: user.profile,
      },
    };
  }

  async register(dto: { email: string; password: string; username: string }) {
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    const user = await this.prisma.account.create({
      data: {
        email: dto.email,
        username: dto.username,
        passwordHash: hashedPassword,
        profile: {
          create: {
            fullName: dto.username,
          },
        },
      },
      include: { profile: true },
    });

    return {
      id: user.id,
      email: user.email,
      username: user.username,
    };
  }

  async validateUser(userId: string) {
    return this.prisma.account.findUnique({
      where: { id: userId },
      include: { profile: true },
    });
  }
}
