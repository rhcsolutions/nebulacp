const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();
const email = 'admin@localhost';
const username = 'admin';
const password = process.env.ADMIN_PASSWORD;

if (!password) {
  console.error('ADMIN_PASSWORD not provided');
  process.exit(1);
}

(async () => {
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.account.upsert({
    where: { email },
    update: { passwordHash, isActive: true, role: 'ADMIN' },
    create: {
      email,
      username,
      passwordHash,
      isActive: true,
      role: 'ADMIN',
      profile: { create: { fullName: 'Administrator' } },
    },
    include: { profile: true },
  });
  console.log('Admin user ready:', { id: user.id, email: user.email, role: user.role });
  await prisma.$disconnect();
})().catch(async (e) => {
  console.error(e);
  await prisma.$disconnect();
  process.exit(1);
});
