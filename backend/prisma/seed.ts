import { PrismaClient, RoleType } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const roles = [
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.CUSTOMER,
    RoleType.AUDITOR,
  ];

  for (const role of roles) {
    await prisma.role.upsert({
      where: { name: role },
      update: {},
      create: {
        name: role,
      },
    });
  }

  console.log('✅ Roles seeded successfully.');
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
  });