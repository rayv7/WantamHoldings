import {
  Injectable,
  BadRequestException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateCustomerDto } from './dto/create-customer.dto';

@Injectable()
export class CustomerService {

  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async create(dto: CreateCustomerDto) {

    const user = await this.prisma.user.findUnique({
      where: {
        id: dto.userId,
      },
    });

    if (!user) {
      throw new BadRequestException(
        'User not found',
      );
    }

    return this.prisma.customer.create({
      data: {
        firstName: dto.firstName,
        lastName: dto.lastName,
        nationalId: dto.nationalId,
        phone: dto.phone,
        userId: dto.userId,
      },
      include: {
        user: true,
      },
    });
  }
}