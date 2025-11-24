import { Controller, Get, Post, Delete, Body, Param, Req, UseGuards } from '@nestjs/common';
import { DomainsService } from './domains.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('domains')
@UseGuards(JwtAuthGuard)
export class DomainsController {
  constructor(private readonly domainsService: DomainsService) {}

  @Get()
  async getAll(@Req() req) {
    return this.domainsService.findAll(req.user.id);
  }

  @Post()
  async create(@Body() dto: any, @Req() req) {
    return this.domainsService.create(dto, req.user.id);
  }

  @Get(':id')
  async getOne(@Param('id') id: string, @Req() req) {
    return this.domainsService.findOne(id, req.user.id);
  }

  @Post(':id/ssl')
  async enableSsl(@Param('id') id: string, @Req() req) {
    return this.domainsService.enableSsl(id, req.user.id);
  }

  @Delete(':id')
  async remove(@Param('id') id: string, @Req() req) {
    return this.domainsService.remove(id, req.user.id);
  }
}
