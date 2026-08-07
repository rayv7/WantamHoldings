import { ApiProperty } from '@nestjs/swagger';

import {
  IsDecimal,
  IsNotEmpty,
  IsPositive,
  IsString,
} from 'class-validator';

export class ChargeDto {
  @ApiProperty({
    example: 'WH0000000001',
  })
  @IsString()
  @IsNotEmpty()
  accountNumber!: string;

  @ApiProperty({
    example: 50,
  })
  @IsPositive()
  @IsDecimal()
  amount!: string;

  @ApiProperty({
    example: 'Monthly Maintenance Fee',
  })
  @IsString()
  @IsNotEmpty()
  description!: string;
}