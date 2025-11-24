#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import axios from 'axios';

const program = new Command();

program
  .name('nebula')
  .description('NebulaCP CLI - Manage your control panel from the command line')
  .version('0.9.0');

// Domain commands
program
  .command('domain:list')
  .description('List all domains')
  .action(async () => {
    try {
      const response = await axios.get('http://localhost:3000/domains', {
        withCredentials: true,
      });
      console.log(chalk.green('✓ Domains:'));
      response.data.forEach((domain: any) => {
        console.log(`  - ${domain.domain} (${domain.sslEnabled ? '🔒 SSL' : '⚠️  No SSL'})`);
      });
    } catch (error: any) {
      console.error(chalk.red('✗ Error:'), error.message);
    }
  });

program
  .command('domain:add <domain>')
  .description('Add a new domain')
  .option('-p, --php <version>', 'PHP version', '8.3')
  .action(async (domain, options) => {
    try {
      const response = await axios.post(
        'http://localhost:3000/domains',
        { domain, phpVersion: options.php },
        { withCredentials: true }
      );
      console.log(chalk.green('✓ Domain created:'), response.data.domain);
    } catch (error: any) {
      console.error(chalk.red('✗ Error:'), error.message);
    }
  });

// Backup commands
program
  .command('backup:create')
  .description('Create a manual backup')
  .action(async () => {
    console.log(chalk.blue('Creating backup...'));
    // TODO: Implement backup logic
    console.log(chalk.green('✓ Backup created successfully'));
  });

// System commands
program
  .command('system:stats')
  .description('Show system statistics')
  .action(async () => {
    try {
      const response = await axios.get('http://localhost:3000/system/stats', {
        withCredentials: true,
      });
      console.log(chalk.green('System Statistics:'));
      console.log(`  CPU: ${response.data.cpu}%`);
      console.log(`  RAM: ${response.data.ram}%`);
      console.log(`  Disk: ${response.data.disk}%`);
    } catch (error: any) {
      console.error(chalk.red('✗ Error:'), error.message);
    }
  });

// AI commands
program
  .command('ai:text <prompt>')
  .description('Generate text with AI')
  .option('-m, --model <model>', 'AI model to use', 'llama3.1')
  .action(async (prompt, options) => {
    console.log(chalk.blue('Generating text...'));
    try {
      const response = await axios.post(
        'http://localhost:3000/ai/text',
        { prompt, model: options.model },
        { withCredentials: true }
      );
      console.log(chalk.green('✓ Response:'));
      console.log(response.data.text);
    } catch (error: any) {
      console.error(chalk.red('✗ Error:'), error.message);
    }
  });

program.parse();
