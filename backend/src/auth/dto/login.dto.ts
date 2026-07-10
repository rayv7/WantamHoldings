import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    example: 'admin@wantam.com',
    description: 'Registered email address',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    example: 'Password123',
    description: 'User password',
  })
  @IsString()
  password!: string;
}