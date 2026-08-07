import {
  IsDecimal,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsString,
  MaxLength,
} from 'class-validator';

import { ApiProperty } from '@nestjs/swagger';

export class DepositDto {
  @ApiProperty({
    example: 'WH0000000001',
  })
  @IsString()
  @IsNotEmpty()
  accountNumber!: string;

  @ApiProperty({
    example: 5000,
  })
  @IsPositive()
  @IsDecimal(
    {
      decimal_digits: '0,2',
    },
    {
      message: 'Amount must be a valid decimal',
    },
  )
  amount!: string;

  @ApiProperty({
    required: false,
    example: 'Cash Deposit',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  description?: string;
}