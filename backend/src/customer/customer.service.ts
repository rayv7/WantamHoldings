import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

import { CreateCustomerDto } from './dto/create-customer.dto';
import { QueryCustomerDto } from './dto/query-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';

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

    const existingCustomer = await this.prisma.customer.findUnique({
      where: {
        userId: dto.userId,
      },
    });

    if (existingCustomer) {
      throw new BadRequestException(
        'This user already has a customer profile.',
      );
    }

    const nationalIdExists = await this.prisma.customer.findUnique({
      where: {
        nationalId: dto.nationalId,
      },
    });

    if (nationalIdExists) {
      throw new BadRequestException(
        'National ID already exists.',
      );
    }

    const phoneExists = await this.prisma.customer.findUnique({
      where: {
        phone: dto.phone,
      },
    });

    if (phoneExists) {
      throw new BadRequestException(
        'Phone number already exists.',
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

  async findAll(query: QueryCustomerDto) {
    const { page, limit, search, status } = query;

    const skip = (page - 1) * limit;

    const where: Prisma.CustomerWhereInput = {
      ...(status && { status }),

      ...(search && {
        OR: [
          {
            firstName: {
              contains: search,
              mode: 'insensitive',
            },
          },
          {
            lastName: {
              contains: search,
              mode: 'insensitive',
            },
          },
          {
            nationalId: {
              contains: search,
              mode: 'insensitive',
            },
          },
          {
            phone: {
              contains: search,
              mode: 'insensitive',
            },
          },
          {
            user: {
              email: {
                contains: search,
                mode: 'insensitive',
              },
            },
          },
        ],
      }),
    };

    const [customers, total] = await this.prisma.$transaction([
      this.prisma.customer.findMany({
        where,
        skip,
        take: limit,

        include: {
          user: {
            select: {
              id: true,
              email: true,
            },
          },
        },

        orderBy: {
          createdAt: 'desc',
        },
      }),

      this.prisma.customer.count({
        where,
      }),
    ]);

    return {
      data: customers,

      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const customer = await this.prisma.customer.findUnique({
      where: {
        id,
      },

      include: {
        user: {
          select: {
            id: true,
            email: true,
            role: true,
          },
        },

        accounts: true,
      },
    });

    if (!customer) {
      throw new NotFoundException(
        'Customer not found',
      );
    }

    return customer;
  }

  async update(id: string, dto: UpdateCustomerDto) {
    const customer = await this.prisma.customer.findUnique({
      where: {
        id,
      },
    });

    if (!customer) {
      throw new NotFoundException(
        'Customer not found',
      );
    }

    if (dto.phone && dto.phone !== customer.phone) {
      const existingPhone = await this.prisma.customer.findUnique({
        where: {
          phone: dto.phone,
        },
      });

      if (existingPhone) {
        throw new BadRequestException(
          'Phone number already exists.',
        );
      }
    }

    return this.prisma.customer.update({
      where: {
        id,
      },

      data: {
        firstName: dto.firstName,
        lastName: dto.lastName,
        phone: dto.phone,
        status: dto.status,
      },

      include: {
        user: {
          select: {
            id: true,
            email: true,
            role: true,
          },
        },
      },
    });
  }
}