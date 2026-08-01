import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        role: true,
        customer: {
          include: {
            accounts: {
              select: {
                accountNumber: true,
                accountType: true,
                currency: true,
                status: true,
              },
            },
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found.');
    }

    return {
      id: user.id,
      email: user.email,
      role: user.role.name,
      customer: user.customer,
      createdAt: user.createdAt,
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    if (!dto.email) {
      throw new BadRequestException(
        'Provide an email address to update your profile.',
      );
    }

    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (existingUser && existingUser.id !== userId) {
      throw new BadRequestException('Email already exists.');
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: { email: dto.email },
    });

    return this.getProfile(userId);
  }
}
