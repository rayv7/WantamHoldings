import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsString,
  MinLength,
  IsNotEmpty,
  IsPhoneNumber,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({
    example: 'admin@wantam.com',
    description: 'The email address used to register the account.',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    example: 'Password123',
    description: 'User password. Must be at least 8 characters long.',
    minLength: 8,
  })
  @IsString()
  @MinLength(8)
  password!: string;

  @ApiProperty({
    example: 'cmcl7v6k00000xyz123456789',
    description: 'The ID of the role assigned to the user.',
  })
  @IsString()
  @IsNotEmpty()
  roleId!: string;

  @ApiProperty({
    example: 'Enoch',
    description: 'Customer first name.',
  })
  @IsString()
  @IsNotEmpty()
  firstName!: string;

  @ApiProperty({
    example: 'Robert',
    description: 'Customer middle name.',
    required: false,
  })
  @IsString()
  middleName?: string;

  @ApiProperty({
    example: 'Obutu',
    description: 'Customer last name.',
  })
  @IsString()
  @IsNotEmpty()
  lastName!: string;

  @ApiProperty({
    example: '12345678',
    description: 'Customer national ID number.',
  })
  @IsString()
  @IsNotEmpty()
  nationalId!: string;

  @ApiProperty({
    example: '+254712345678',
    description: 'Customer phone number used for USSD identification.',
  })
  @IsPhoneNumber('KE')
  phone!: string;
}