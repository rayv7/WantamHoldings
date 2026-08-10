import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UssdService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async handleUssd(body: any) {
    const phoneNumber = body.phoneNumber;
    const text = body.text || '';

    // Phone number is required
    if (!phoneNumber) {
      return {
        response: 'END Phone number is required.',
      };
    }

    // Find customer using phone number
    const customer = await this.prisma.customer.findUnique({
      where: {
        phone: phoneNumber,
      },
      include: {
        accounts: true,
      },
    });

    // Customer does not exist
    if (!customer) {
      return {
        response: 'END You are not registered with Wantam Holdings.',
      };
    }

    // Get the first active account
    const account = customer.accounts.find(
      (acc) => acc.status === 'ACTIVE',
    );

    // No active account
    if (!account) {
      return {
        response: 'END No active account was found for your profile.',
      };
    }

    // Split USSD input
    // Example:
    // "2"       -> Deposit
    // "2*5000"  -> Deposit KES 5000
    // "3"       -> Withdraw
    // "3*2000"  -> Withdraw KES 2000
    const parts = text.split('*');

    // If there is no option selected, show main menu
    if (!text || text.trim() === '') {
      return {
        response:
          `CON Welcome ${customer.firstName} ${customer.lastName}\n` +
          `1. Check Balance` +
          `2. Deposit` +
          `3. Withdraw` +
          `4. Mini Statement`,
      };
    }

    
    // 1. CHECK BALANCE
    
    if (parts[0] === '1') {
      const balance = Number(account.balance).toFixed(2);

      return {
        response:
          `END Account Balance` +
          `Available Balance: KES ${balance}`,
      };
    }

    // 2. DEPOSIT

    if (parts[0] === '2') {
      // User selected Deposit but has not entered amount
      if (!parts[1]) {
        return {
          response: 'CON Enter amount to deposit:',
        };
      }

      const amount = Number(parts[1]);

      // Validate amount
      if (isNaN(amount) || amount <= 0) {
        return {
          response: 'END Please enter a valid deposit amount.',
        };
      }

      // Prevent extremely small/invalid decimal values
      if (!Number.isFinite(amount)) {
        return {
          response: 'END Invalid deposit amount.',
        };
      }

      // Create transaction and update account balance
      const result = await this.prisma.$transaction(async (tx) => {
        const newBalance =
          Number(account.balance) + amount;

        const updatedAccount = await tx.account.update({
          where: {
            id: account.id,
          },
          data: {
            balance: new Prisma.Decimal(newBalance),
          },
        });

        const transaction = await tx.transaction.create({
          data: {
            reference: `USSD-DEP-${Date.now()}-${randomUUID().slice(0, 8)}`,
            amount: new Prisma.Decimal(amount),
            type: 'DEPOSIT',
            status: 'COMPLETED',
            description: 'USSD deposit',
            accountId: account.id,
          },
        });

        return {
          account: updatedAccount,
          transaction,
        };
      });

      return {
        response:
          `END Deposit successful.` +
          `Amount: KES ${amount.toFixed(2)}` +
          `New Balance: KES ${Number(result.account.balance).toFixed(2)}`,
      };
    }

    // 3. WITHDRAW

    if (parts[0] === '3') {
      // User selected Withdraw but has not entered amount
      if (!parts[1]) {
        return {
          response: 'CON Enter amount to withdraw:',
        };
      }

      const amount = Number(parts[1]);

      // Validate amount
      if (isNaN(amount) || amount <= 0) {
        return {
          response: 'END Please enter a valid withdrawal amount.',
        };
      }

      if (!Number.isFinite(amount)) {
        return {
          response: 'END Invalid withdrawal amount.',
        };
      }

      const currentBalance = Number(account.balance);

      // Check sufficient funds
      if (amount > currentBalance) {
        return {
          response:
            `END Insufficient funds.\n` +
            `Available Balance: KES ${currentBalance.toFixed(2)}`,
        };
      }

      // Update balance and create transaction atomically
      const result = await this.prisma.$transaction(async (tx) => {
        const newBalance =
          currentBalance - amount;

        const updatedAccount = await tx.account.update({
          where: {
            id: account.id,
          },
          data: {
            balance: new Prisma.Decimal(newBalance),
          },
        });

        const transaction = await tx.transaction.create({
          data: {
            reference: `USSD-WD-${Date.now()}-${randomUUID().slice(0, 8)}`,
            amount: new Prisma.Decimal(amount),
            type: 'WITHDRAWAL',
            status: 'COMPLETED',
            description: 'USSD withdrawal',
            accountId: account.id,
          },
        });

        return {
          account: updatedAccount,
          transaction,
        };
      });

      return {
        response:
          `END Withdrawal successful.\n` +
          `Amount: KES ${amount.toFixed(2)}` +
          `New Balance: KES ${Number(result.account.balance).toFixed(2)}`,
      };
    }


// 4. MINI STATEMENT

if (parts[0] === '4') {
  const transactions =
    await this.prisma.transaction.findMany({
      where: {
        accountId: account.id,
        status: 'COMPLETED',
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: 5,
    });

  if (transactions.length === 0) {
    return {
      response: 'END No transactions found.',
    };
  }

  let response = 'END Mini Statement';

  for (const transaction of transactions) {
    const amount = Number(transaction.amount).toFixed(2);

    let transactionType: string;

    switch (transaction.type) {
      case 'DEPOSIT':
        transactionType = 'Deposit';
        break;

      case 'WITHDRAWAL':
        transactionType = 'Withdrawal';
        break;

      case 'TRANSFER':
        transactionType = 'Transfer';
        break;

      case 'REVERSAL':
        transactionType = 'Reversal';
        break;

      case 'INTEREST':
        transactionType = 'Interest';
        break;

      case 'CHARGE':
        transactionType = 'Charge';
        break;

      default:
        transactionType = transaction.type;
    }

    response += `${transactionType}: KES ${amount}\n`;
  }

  return {
    response: response.trim(),
  };
}
    
    // INVALID OPTION

    return {
      response:
        `END Invalid option.\n` +
        `Please dial *123# and try again.`,
    };
  }
}