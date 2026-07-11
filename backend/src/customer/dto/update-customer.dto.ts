import { PartialType } from '@nestjs/swagger';
import { CreateCustomerDto } from './create-customer.dto';

import { IsEnum, IsOptional, IsString } from 'class-validator';
import { CustomerStatus } from '@prisma/client';

export class UpdateCustomerDto extends PartialType(CreateCustomerDto) {

  @IsOptional()
  @IsString()
  firstName?: string;

  @IsOptional()
  @IsString()
  lastName?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsEnum(CustomerStatus)
  status?: CustomerStatus;
}