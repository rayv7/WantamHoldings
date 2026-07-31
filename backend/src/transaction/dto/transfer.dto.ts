import {
  IsDecimal,
  IsNotEmpty,
  IsPositive,
  IsString,
  MaxLength,
  IsOptional,
} from 'class-validator';

import { ApiProperty } from '@nestjs/swagger';

export class TransferDto {
  @ApiProperty({
    example: 'WH0000000001',
  })
  @IsString()
  @IsNotEmpty()
  senderAccountNumber!: string;

  @ApiProperty({
    example: 'WH0000000002',
  })
  @IsString()
  @IsNotEmpty()
  receiverAccountNumber!: string;

  @ApiProperty({
    example: 1000,
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
    example: 'School Fees',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  description?: string;
}