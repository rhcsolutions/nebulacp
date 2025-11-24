import { Controller, Post, Body, Req, UseGuards } from '@nestjs/common';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('text')
  async generateText(@Body() { prompt, model }: { prompt: string; model?: string }, @Req() req) {
    const result = await this.aiService.generateText(prompt, model || 'llama3.1');
    
    // Log usage
    await this.aiService.logUsage({
      userId: req.user.id,
      type: 'TEXT',
      model: model || 'llama3.1',
      prompt,
      cost: 0,
    });

    return result;
  }

  @Post('image')
  async generateImage(@Body() { prompt, steps }: { prompt: string; steps?: number }, @Req() req) {
    const result = await this.aiService.generateImage(prompt, steps || 20);
    
    // Log usage
    await this.aiService.logUsage({
      userId: req.user.id,
      type: 'IMAGE',
      model: 'comfyui',
      prompt,
      cost: 0,
    });

    return result;
  }
}
