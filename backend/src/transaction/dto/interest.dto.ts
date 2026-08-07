import { ApiProperty } from '@nestjs/swagger';

import {
  IsDecimal,
  IsNotEmpty,
  IsPositive,
  IsString,
} from 'class-validator';

export class InterestDto {
  @ApiProperty({
    example: 'WH0000000001',
  })
  @IsString()
  @IsNotEmpty()
  accountNumber!: string;

  @ApiProperty({
    example: 250,
  })
  @IsPositive()
  @IsDecimal()
  amount!: string;
}