import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class UssdDto {
  @ApiProperty({
    example: '+254700785908',
    description: 'Customer phone number',
  })
  @IsString()
  @IsNotEmpty()
  phoneNumber!: string;

  @ApiProperty({
    example: '*123#',
    description: 'USSD service code',
  })
  @IsString()
  @IsNotEmpty()
  serviceCode!: string;

  @ApiProperty({
    example: '1',
    description: 'USSD input from the customer',
  })
  @IsString()
  @IsNotEmpty()
  text!: string;
}