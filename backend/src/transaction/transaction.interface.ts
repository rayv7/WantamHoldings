import { Transaction } from '@prisma/client';

export interface TransactionResult {
  message: string;

  transaction: Transaction;

  balance: string;
}