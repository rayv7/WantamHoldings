import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  Account,
  AccountStatus,
  AccountType,
  CustomerStatus,
  Prisma,
} from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

import { CreateAccountDto } from './dto/create-account.dto';
import { QueryAccountDto } from './dto/query-account.dto';
import { UpdateAccountDto } from './dto/update-account.dto';

@Injectable()
export class AccountService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  /*
  |--------------------------------------------------------------------------
  | Create Account
  |--------------------------------------------------------------------------
  */

  async create(
    dto: CreateAccountDto,
  ) {
    const customer =
      await this.validateCustomer(
        dto.customerId,
      );

    const accountNumber =
      await this.generateAccountNumber();

    const accountName =
      this.generateAccountName(
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

        balance: new Prisma.Decimal(0),

        currency: 'KES',
      },

      include: {
        customer: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
              },
            },
          },
        },
      },
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Get Accounts
  |--------------------------------------------------------------------------
  */
async findAll(query: QueryAccountDto) {
  const {
    page = 1,
    limit = 10,
    search,
    status,
    accountType,
    customerId,
  } = query;

  const skip = (page - 1) * limit;

  const where: Prisma.AccountWhereInput = {};

  // Status Filter
  if (status) {
    where.status = status;
  }

  // Account Type Filter
  if (accountType) {
    where.accountType = accountType;
  }

  // Customer Filter
  if (customerId) {
    where.customerId = customerId;
  }

  // Search Filter
  if (search) {
    where.OR = [
      {
        accountNumber: {
          contains: search,
          mode: 'insensitive',
        },
      },
      {
        customer: {
          firstName: {
            contains: search,
            mode: 'insensitive',
          },
        },
      },
      {
        customer: {
          lastName: {
            contains: search,
            mode: 'insensitive',
          },
        },
      },
      {
        customer: {
          user: {
            email: {
              contains: search,
              mode: 'insensitive',
            },
          },
        },
      },
    ];
  }

  const [accounts, total] = await this.prisma.$transaction([
    this.prisma.account.findMany({
      where,
      skip,
      take: limit,

      include: {
        customer: {
          include: {
            user: {
              select: {
                id: true,
                email: true,
                role: true,
              },
            },
          },
        },

        _count: {
          select: {
            transactions: true,
          },
        },
      },

      orderBy: {
        createdAt: 'desc',
      },
    }),

    this.prisma.account.count({
      where,
    }),
  ]);

  return {
    data: accounts,

    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}

  /*
  |--------------------------------------------------------------------------
  | Get Account By ID
  |--------------------------------------------------------------------------
  */

  async findOne(id: string) {
    const account =
      await this.prisma.account.findUnique({
        where: {
          id,
        },

        include: {
          customer: {
            include: {
              user: {
                select: {
                  id: true,
                  email: true,
                },
              },
            },
          },

          transactions: {
            orderBy: {
              createdAt: 'desc',
            },
          },
        },
      });

    if (!account) {
      throw new NotFoundException(
        'Account not found.',
      );
    }

    return account;
  }

  /*
  |--------------------------------------------------------------------------
  | Get Account By Account Number
  |--------------------------------------------------------------------------
  */

  async findByAccountNumber(
    accountNumber: string,
  ) {
    const account =
      await this.prisma.account.findUnique({
        where: {
          accountNumber,
        },

        select: {
          accountNumber: true,
          accountType: true,
          balance: true,
          currency: true,
          status: true,
          customer: {
            select: {
              firstName: true,
              lastName: true,
              user: {
                select: {
                  id: true,
                  email: true,
                },
              },
            },
          },
        },
      });

    if (!account) {
      throw new NotFoundException(
        'Account not found.',
      );
    }

    return account;
  }

  /*
  |--------------------------------------------------------------------------
  | Customer Accounts
  |--------------------------------------------------------------------------
  */

  async findCustomerAccounts(
    customerId: string,
  ) {
    return this.prisma.account.findMany({
      where: {
        customerId,
      },

      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Update Account
  |--------------------------------------------------------------------------
  */

  async update(
    id: string,
    dto: UpdateAccountDto,
  ) {
    await this.findOne(id);

    return this.prisma.account.update({
      where: {
        id,
      },

      data: {
        accountName: dto.accountName,
        status: dto.status,
      },
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Freeze
  |--------------------------------------------------------------------------
  */

  async freezeAccount(
    id: string,
  ) {
    await this.findOne(id);

    return this.prisma.account.update({
      where: {
        id,
      },

      data: {
        status: AccountStatus.FROZEN,
      },
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Activate
  |--------------------------------------------------------------------------
  */

  async activateAccount(
    id: string,
  ) {
    await this.findOne(id);

    return this.prisma.account.update({
      where: {
        id,
      },

      data: {
        status: AccountStatus.ACTIVE,
      },
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Close
  |--------------------------------------------------------------------------
  */

  async closeAccount(
    id: string,
  ) {
    const account =
      await this.findOne(id);

    if (
      account.balance.greaterThan(0)
    ) {
      throw new BadRequestException(
        'Account still has money. Withdraw or transfer remaining balance first.',
      );
    }

    return this.prisma.account.update({
      where: {
        id,
      },

      data: {
        status: AccountStatus.CLOSED,
      },
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Balance
  |--------------------------------------------------------------------------
  */

  async getBalance(
    accountNumber: string,
  ) {
    const account =
      await this.findByAccountNumber(
        accountNumber,
      );

    return {
      accountNumber:
        account.accountNumber,

      accountName:
        this.generateAccountName(
          account.customer.firstName,
          account.customer.lastName,
          account.accountType,
        ),

      balance:
        account.balance,

      currency:
        account.currency,

      status:
        account.status,
    };
  }

  /*
  |--------------------------------------------------------------------------
  | Helpers
  |--------------------------------------------------------------------------
  */

  private async validateCustomer(
    customerId: string,
  ) {
    const customer =
      await this.prisma.customer.findUnique({
        where: {
          id: customerId,
        },
      });

    if (!customer) {
      throw new NotFoundException(
        'Customer not found.',
      );
    }

    if (
      customer.status !==
      CustomerStatus.ACTIVE
    ) {
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
    const year =
      new Date()
        .getFullYear()
        .toString()
        .slice(-2);

    const count =
      await this.prisma.account.count();

    const sequence =
      (count + 1)
        .toString()
        .padStart(9, '0');

    return `WH${year}${sequence}`;
  }
}