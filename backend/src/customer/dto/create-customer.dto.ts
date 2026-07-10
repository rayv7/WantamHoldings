import {
  IsNotEmpty,
  IsString,
} from 'class-validator';

import { ApiProperty } from '@nestjs/swagger';

export class CreateCustomerDto {

  @ApiProperty({
    example: 'John',
  })
  @IsString()
  @IsNotEmpty()
  firstName!: string;

  @ApiProperty({
    example: 'Doe',
  })
  @IsString()
  @IsNotEmpty()
  lastName!: string;

  @ApiProperty({
    example: '12345678',
  })
  @IsString()
  @IsNotEmpty()
  nationalId!: string;

  @ApiProperty({
    example: '+254712345678',
  })
  @IsString()
  @IsNotEmpty()
  phone!: string;

  @ApiProperty({
    description: 'Existing User ID',
  })
  @IsString()
  @IsNotEmpty()
  userId!: string;
}