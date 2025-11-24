import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from 'nestjs-prisma';
import axios from 'axios';

@Injectable()
export class AiService {
  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
  ) {}

  async generateText(prompt: string, model: string) {
    const ollamaUrl = this.config.get('ollama.url');

    try {
      const response = await axios.post(`${ollamaUrl}/api/generate`, {
        model,
        prompt,
        stream: false,
      });

      return {
        text: response.data.response,
        model,
      };
    } catch (error) {
      throw new Error(`Ollama error: ${error.message}`);
    }
  }

  async generateImage(prompt: string, steps: number = 20) {
    const comfyuiUrl = this.config.get('comfyui.url');

    try {
      // Simplified ComfyUI workflow
      const workflow = {
        prompt: {
          "3": {
            "inputs": {
              "seed": Math.floor(Math.random() * 1000000),
              "steps": steps,
              "cfg": 7,
              "sampler_name": "euler",
              "scheduler": "normal",
              "denoise": 1,
              "model": ["4", 0],
              "positive": ["6", 0],
              "negative": ["7", 0],
              "latent_image": ["5", 0]
            },
            "class_type": "KSampler"
          },
          "6": {
            "inputs": {
              "text": prompt,
              "clip": ["4", 1]
            },
            "class_type": "CLIPTextEncode"
          },
          // ... more nodes
        }
      };

      const response = await axios.post(`${comfyuiUrl}/prompt`, workflow);

      return {
        imageUrl: `/generated/${response.data.prompt_id}.png`,
        prompt,
      };
    } catch (error) {
      throw new Error(`ComfyUI error: ${error.message}`);
    }
  }

  async logUsage(data: {
    userId: string;
    type: 'TEXT' | 'IMAGE';
    model: string;
    prompt: string;
    cost: number;
  }) {
    return this.prisma.aiUsage.create({
      data,
    });
  }
}
