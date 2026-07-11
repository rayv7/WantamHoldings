import { ApiProperty } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsString,
} from 'class-validator';

import { AccountType } from '@prisma/client';

export class CreateAccountDto {
  @ApiProperty({
    description: 'Customer ID',
    example: 'cmf9v5n0q0000j2b0s8q7t2w1',
  })
  @IsString()
  @IsNotEmpty()
  customerId!: string;

  @ApiProperty({
    enum: AccountType,
    example: AccountType.SAVINGS,
  })
  @IsEnum(AccountType)
  accountType!: AccountType;
}