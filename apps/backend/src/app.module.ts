import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from 'nestjs-prisma';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { DomainsModule } from './modules/domains/domains.module';
import { BackupModule } from './modules/backup/backup.module';
import { AiModule } from './modules/ai/ai.module';
import { FileManagerModule } from './modules/filemanager/filemanager.module';
import { DatabaseModule } from './modules/database/database.module';
import { MailModule } from './modules/mail/mail.module';
import { DnsModule } from './modules/dns/dns.module';
import { SystemModule } from './modules/system/system.module';
import configuration from './config/configuration';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    PrismaModule.forRoot({
      isGlobal: true,
    }),
    AuthModule,
    UsersModule,
    DomainsModule,
    BackupModule,
    AiModule,
    FileManagerModule,
    DatabaseModule,
    MailModule,
    DnsModule,
    SystemModule,
  ],
})
export class AppModule {}
