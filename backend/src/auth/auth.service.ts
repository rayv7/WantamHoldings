import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { JwtService } from '@nestjs/jwt';

import * as bcrypt from 'bcrypt';

import { PrismaService } from '../prisma/prisma.service';

import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

import { JwtPayload } from './interfaces/jwt-payload.interface';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  /*
  |--------------------------------------------------------------------------
  | Register
  |--------------------------------------------------------------------------
  */

  async register(dto: RegisterDto) {
    const existingUser =
      await this.prisma.user.findUnique({
        where: {
          email: dto.email,
        },
      });

    if (existingUser) {
      throw new BadRequestException(
        'Email already exists.',
      );
    }

    const hashedPassword =
      await bcrypt.hash(dto.password, 10);

    const user =
      await this.prisma.user.create({
        data: {
          email: dto.email,
          password: hashedPassword,
          roleId: dto.roleId,
        },

        include: {
          role: true,
        },
      });

    return {
      success: true,

      message:
        'User registered successfully.',

      user: {
        id: user.id,
        email: user.email,
        role: user.role.name,
        createdAt: user.createdAt,
      },
    };
  }

  /*
  |--------------------------------------------------------------------------
  | Login
  |--------------------------------------------------------------------------
  */

  async login(dto: LoginDto) {
    const user =
      await this.prisma.user.findUnique({
        where: {
          email: dto.email,
        },

        include: {
          role: true,
        },
      });

    if (!user) {
      throw new UnauthorizedException(
        'Invalid email or password.',
      );
    }

    const passwordMatches =
      await bcrypt.compare(
        dto.password,
        user.password,
      );

    if (!passwordMatches) {
      throw new UnauthorizedException(
        'Invalid email or password.',
      );
    }

    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role.name,
    };

    const accessToken =
      await this.jwtService.signAsync(
        payload,
      );

    return {
      success: true,

      message:
        'Login successful.',

      accessToken,

      tokenType: 'Bearer',

      user: {
        id: user.id,
        email: user.email,
        role: user.role.name,
      },
    };
  }

  /*
  |--------------------------------------------------------------------------
  | Validate User
  |--------------------------------------------------------------------------
  */

  async validateUser(
    id: string,
  ) {
    return this.prisma.user.findUnique({
      where: {
        id,
      },

      include: {
        role: true,
      },
    });
  }
}