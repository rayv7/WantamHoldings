import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  AccountType,
  CustomerStatus,
} from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

import { CreateAccountDto } from './dto/create-account.dto';

@Injectable()
export class AccountService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async create(dto: CreateAccountDto) {
    const customer = await this.validateCustomer(dto.customerId);

    const accountNumber = await this.generateAccountNumber();

    const accountName = this.generateAccountName(
      customer.firstName,
      customer.lastName,
      dto.accountType,
    );

    return this.prisma.account.create({
      data: {
        customerId: customer.id,
        accountNumber,
        accountName,
        accountType: dto.accountType,
        balance: 0,
      },
      include: {
        customer: {
          include: {
            user: {
              select: {
                email: true,
              },
            },
          },
        },
      },
    });
  }

  async findAll() {
    return this.prisma.account.findMany({
      include: {
        customer: {
          include: {
            user: {
              select: {
                email: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(id: string) {
    const account = await this.prisma.account.findUnique({
      where: { id },
      include: {
        customer: {
          include: {
            user: {
              select: {
                email: true,
              },
            },
          },
        },
        transactions: true,
      },
    });

    if (!account) {
      throw new NotFoundException('Account not found');
    }

    return account;
  }

  private async validateCustomer(customerId: string) {
    const customer = await this.prisma.customer.findUnique({
      where: {
        id: customerId,
      },
    });

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    if (customer.status !== CustomerStatus.ACTIVE) {
      throw new BadRequestException(
        'Customer account is not active.',
      );
    }

    return customer;
  }

  private generateAccountName(
    firstName: string,
    lastName: string,
    accountType: AccountType,
  ) {
    return `${firstName} ${lastName} ${accountType} Account`;
  }

  private async generateAccountNumber() {
    const year = new Date().getFullYear().toString().slice(-2);

    const count = await this.prisma.account.count();

    const sequence = (count + 1)
      .toString()
      .padStart(9, '0');

    return `WH${year}${sequence}`;
  }
}