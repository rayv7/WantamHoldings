import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsString,
  MinLength,
  IsNotEmpty,
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
}