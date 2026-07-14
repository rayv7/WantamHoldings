import { ApiProperty } from '@nestjs/swagger';

import { IsNotEmpty, IsString } from 'class-validator';

export class ReverseTransactionDto {
  @ApiProperty({
    example: 'TXN202607120001',
  })
  @IsString()
  @IsNotEmpty()
  reference!: string;
}