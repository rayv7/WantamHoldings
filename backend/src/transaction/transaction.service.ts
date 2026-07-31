import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  Account,
  AccountStatus,
  Prisma,
  TransactionType,
  TransactionStatus,
} from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';

import { DepositDto } from './dto/deposit.dto';
import { WithdrawDto } from './dto/withdraw.dto';
import { TransferDto } from './dto/transfer.dto';
import { ReverseTransactionDto } from './dto/reverse-transaction.dto';
import { InterestDto } from './dto/interest.dto';
import { ChargeDto } from './dto/charge.dto';
import { StatementDto } from './dto/statement.dto';

@Injectable()
export class TransactionService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  /*
  |--------------------------------------------------------------------------
  | Helper Methods
  |--------------------------------------------------------------------------
  */

  /**
   * Fetch account by account number.
   */
  private async getAccount(
    accountNumber: string,
  ): Promise<Account> {
    const account =
      await this.prisma.account.findUnique({
        where: {
          accountNumber,
        },
      });

    if (!account) {
      throw new NotFoundException(
        'Account not found.',
      );
    }

    return account;
  }

  /**
   * Ensure account can transact.
   */
  private validateAccount(
    account: Account,
  ) {
    if (account.status !== AccountStatus.ACTIVE) {
      throw new BadRequestException(
        'Account is not active.',
      );
    }
  }

  /**
   * Generates a unique transaction reference.
   */
  private async generateReference(): Promise<string> {
    const count =
      await this.prisma.transaction.count();

    const sequence = (count + 1)
      .toString()
      .padStart(8, '0');

    return `TXN${new Date().getFullYear()}${sequence}`;
  }

  /**
   * Convert value to Prisma Decimal.
   */
  private toDecimal(
    value: Prisma.Decimal | string | number,
  ) {
    return new Prisma.Decimal(value);
  }

  /**
   * Create audit log.
   */
  private async createAudit(
    tx: Prisma.TransactionClient,
    action: string,
    description: string,
    userId: string,
  ) {
    return tx.auditLog.create({
      data: {
        action,
        description,
        userId,
      },
    });
  }

  /*
  |--------------------------------------------------------------------------
  | Deposit
  |--------------------------------------------------------------------------
  */

  async deposit(
    dto: DepositDto,
    user: any,
  ) {
    const account =
      await this.getAccount(
        dto.accountNumber,
      );

    this.validateAccount(account);

    const amount =
      this.toDecimal(dto.amount);

    return this.prisma.$transaction(
      async (tx) => {

        const balanceBefore =
          account.balance;

        const balanceAfter =
          balanceBefore.plus(amount);

        const transaction =
          await tx.transaction.create({
            data: {
              reference:
                await this.generateReference(),

              amount,

              type:
                TransactionType.DEPOSIT,

              status:
                TransactionStatus.COMPLETED,

              description:
                dto.description ??
                'Cash Deposit',

              accountId:
                account.id,

              performedByUserId:
                user.sub,
            },
          });

        await tx.account.update({
          where: {
            id: account.id,
          },

          data: {
            balance: balanceAfter,
          },
        });

        await this.createAudit(
          tx,
          'Deposit',
          `Deposited ${amount} into ${account.accountNumber}`,
          user.sub,
        );

        return {
          success: true,
          message:
            'Deposit successful.',
          transaction,
          balanceBefore,
          balanceAfter,
        };
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Withdrawal
  |--------------------------------------------------------------------------
  */

  async withdraw(
    dto: WithdrawDto,
    user: any,
  ) {
    const account =
      await this.getAccount(
        dto.accountNumber,
      );

    this.validateAccount(account);

    const amount =
      this.toDecimal(dto.amount);

    if (
      account.balance.lessThan(amount)
    ) {
      throw new BadRequestException(
        'Insufficient account balance.',
      );
    }

    return this.prisma.$transaction(
      async (tx) => {

        const balanceBefore =
          account.balance;

        const balanceAfter =
          balanceBefore.minus(amount);

        const transaction =
          await tx.transaction.create({
            data: {
              reference:
                await this.generateReference(),

              amount,

              type:
                TransactionType.WITHDRAWAL,

              status:
                TransactionStatus.COMPLETED,

              description:
                dto.description ??
                'Cash Withdrawal',

              accountId:
                account.id,

              performedByUserId:
                user.sub,
            },
          });

        await tx.account.update({
          where: {
            id: account.id,
          },

          data: {
            balance: balanceAfter,
          },
        });

        await this.createAudit(
          tx,
          'Withdrawal',
          `Withdrawal of ${amount} from ${account.accountNumber}`,
          user.sub,
        );

        return {
          success: true,
          message:
            'Withdrawal successful.',
          transaction,
          balanceBefore,
          balanceAfter,
        };
      },
    );
  }

   /*
  |--------------------------------------------------------------------------
  | Transfer
  |--------------------------------------------------------------------------
  */

  async transfer(
    dto: TransferDto,
    user: any,
  ) {
    if (
      dto.senderAccountNumber ===
      dto.receiverAccountNumber
    ) {
      throw new BadRequestException(
        'Cannot transfer to the same account.',
      );
    }

    const sender =
      await this.getAccount(
        dto.senderAccountNumber,
      );

    const receiver =
      await this.getAccount(
        dto.receiverAccountNumber,
      );

    this.validateAccount(sender);
    this.validateAccount(receiver);

    const amount =
      this.toDecimal(dto.amount);

    if (
      sender.balance.lessThan(amount)
    ) {
      throw new BadRequestException(
        'Insufficient account balance.',
      );
    }

    return this.prisma.$transaction(
      async (tx) => {

        const reference =
          await this.generateReference();

        const senderBalanceBefore =
          sender.balance;

        const senderBalanceAfter =
          sender.balance.minus(amount);

        const receiverBalanceBefore =
          receiver.balance;

        const receiverBalanceAfter =
          receiver.balance.plus(amount);

        await tx.account.update({
          where: {
            id: sender.id,
          },
          data: {
            balance: senderBalanceAfter,
          },
        });

        await tx.account.update({
          where: {
            id: receiver.id,
          },
          data: {
            balance: receiverBalanceAfter,
          },
        });

        const debit =
          await tx.transaction.create({
            data: {
              reference: `${reference}-OUT`,
              amount,
              type: TransactionType.TRANSFER,
              status: TransactionStatus.COMPLETED,
              description:
                dto.description ??
                `Transfer to ${receiver.accountNumber}`,
              accountId: sender.id,
              performedByUserId:
                user.sub,
            },
          });

        const credit =
          await tx.transaction.create({
            data: {
              reference: `${reference}-IN`,
              amount,
              type: TransactionType.TRANSFER,
              status: TransactionStatus.COMPLETED,
              description:
                dto.description ??
                `Transfer from ${sender.accountNumber}`,
              accountId: receiver.id,
              performedByUserId:
                user.sub,
            },
          });

        await tx.transfer.create({
          data: {
            reference,
            amount,
            senderAccountId: sender.id,
            receiverAccountId: receiver.id,
          },
        });

        await this.createAudit(
          tx,
          'Transfer',
          `Transferred ${amount} from ${sender.accountNumber} to ${receiver.accountNumber}`,
          user.sub,
        );

        return {
          success: true,
          message:
            'Transfer completed successfully.',
          reference,
          debitTransaction: debit,
          creditTransaction: credit,
          senderBalanceBefore,
          senderBalanceAfter,
          receiverBalanceBefore,
          receiverBalanceAfter,
        };
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Reverse Transaction
  |--------------------------------------------------------------------------
  */

  async reverse(
    dto: ReverseTransactionDto,
    user: any,
  ) {
    const transaction =
      await this.prisma.transaction.findUnique({
        where: {
          reference: dto.reference,
        },
        include: {
          account: true,
        },
      });

    if (!transaction) {
      throw new NotFoundException(
        'Transaction not found.',
      );
    }

    throw new BadRequestException(
      'Transaction reversal will be implemented after ledger support is added.',
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Interest
  |--------------------------------------------------------------------------
  */

  async applyInterest(
    dto: InterestDto,
    user: any,
  ) {
    const account =
      await this.getAccount(
        dto.accountNumber,
      );

    this.validateAccount(account);

    const amount =
      this.toDecimal(dto.amount);

    return this.prisma.$transaction(
      async (tx) => {

        const balanceBefore =
          account.balance;

        const balanceAfter =
          balanceBefore.plus(amount);

        const transaction =
          await tx.transaction.create({
            data: {
              reference:
                await this.generateReference(),

              amount,

              type:
                TransactionType.DEPOSIT,

              status:
                TransactionStatus.COMPLETED,

              description:
                'Interest Credit',

              accountId:
                account.id,

              performedByUserId:
                user.sub,
            },
          });

        await tx.account.update({
          where: {
            id: account.id,
          },
          data: {
            balance: balanceAfter,
          },
        });

        await this.createAudit(
          tx,
          'Interest',
          `Interest of ${amount} applied to ${account.accountNumber}`,
          user.sub,
        );

        return {
          success: true,
          message:
            'Interest applied successfully.',
          transaction,
          balanceBefore,
          balanceAfter,
        };
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Charges
  |--------------------------------------------------------------------------
  */

  async applyCharge(
    dto: ChargeDto,
    user: any,
  ) {
    const account =
      await this.getAccount(
        dto.accountNumber,
      );

    this.validateAccount(account);

    const amount =
      this.toDecimal(dto.amount);

    if (
      account.balance.lessThan(amount)
    ) {
      throw new BadRequestException(
        'Insufficient account balance.',
      );
    }

    return this.prisma.$transaction(
      async (tx) => {

        const balanceBefore =
          account.balance;

        const balanceAfter =
          balanceBefore.minus(amount);

        const transaction =
          await tx.transaction.create({
            data: {
              reference:
                await this.generateReference(),

              amount,

              type:
                TransactionType.WITHDRAWAL,

              status:
                TransactionStatus.COMPLETED,

              description:
                dto.description,

              accountId:
                account.id,

              performedByUserId:
                user.sub,
            },
          });

        await tx.account.update({
          where: {
            id: account.id,
          },
          data: {
            balance: balanceAfter,
          },
        });

        await this.createAudit(
          tx,
          'Charge',
          `Charge of ${amount} applied to ${account.accountNumber}`,
          user.sub,
        );

        return {
          success: true,
          message:
            'Charge applied successfully.',
          transaction,
          balanceBefore,
          balanceAfter,
        };
      },
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Account Statement
  |--------------------------------------------------------------------------
  */

  async generateStatement(
    accountNumber: string,
    dto: StatementDto,
  ) {
    const account =
      await this.getAccount(
        accountNumber,
      );

    const where: Prisma.TransactionWhereInput = {
      accountId: account.id,
    };

    if (dto.from || dto.to) {
      where.createdAt = {};

      if (dto.from) {
        where.createdAt.gte =
          new Date(dto.from);
      }

      if (dto.to) {
        where.createdAt.lte =
          new Date(dto.to);
      }
    }

    const transactions =
      await this.prisma.transaction.findMany({
        where,
        orderBy: {
          createdAt: 'desc',
        },
      });

    return {
      accountNumber:
        account.accountNumber,
      accountName:
        account.accountType,
      currentBalance:
        account.balance,
      totalTransactions:
        transactions.length,
      transactions,
    };
  }
}