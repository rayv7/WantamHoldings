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

  const existingCustomer =
    await this.prisma.customer.findFirst({
      where: {
        OR: [
          {
            phone: dto.phone,
          },
          {
            nationalId: dto.nationalId,
          },
        ],
      },
    });

  if (existingCustomer) {
    throw new BadRequestException(
      'Phone number or National ID already exists.',
    );
  }

  const role =
    await this.prisma.role.findUnique({
      where: {
        id: dto.roleId,
      },
    });

  if (!role) {
    throw new BadRequestException(
      'Invalid role ID.',
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

        customer: {
          create: {
            firstName: dto.firstName,
            middleName: dto.middleName,
            lastName: dto.lastName,
            nationalId: dto.nationalId,
            phone: dto.phone,
          },
        },
      },

      include: {
        role: true,
        customer: true,
      },
    });

  return {
    success: true,

    message:
      'User and customer registered successfully.',

    user: {
      id: user.id,
      email: user.email,
      role: user.role.name,
      createdAt: user.createdAt,
    },

    customer: {
      id: user.customer?.id,
      firstName: user.customer?.firstName,
      middleName: user.customer?.middleName,
      lastName: user.customer?.lastName,
      nationalId: user.customer?.nationalId,
      phone: user.customer?.phone,
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