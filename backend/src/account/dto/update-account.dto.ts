import { ApiPropertyOptional } from '@nestjs/swagger';
import { AccountStatus } from '@prisma/client';

import {
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class UpdateAccountDto {
  @ApiPropertyOptional({
    example: 'John Doe Savings Account',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  accountName?: string;

  @ApiPropertyOptional({
    enum: AccountStatus,
    example: AccountStatus.ACTIVE,
  })
  @IsOptional()
  @IsEnum(AccountStatus)
  status?: AccountStatus;
} 