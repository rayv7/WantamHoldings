import {
  Body,
  Controller,
  Get,
  Patch,
  Request,
  UseGuards,
} from '@nestjs/common';
import { Request as ExpressRequest } from 'express';

import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { JwtGuard } from '../auth/guards/jwt.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@ApiTags('Users')
@ApiBearerAuth('JWT-auth')
@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
  ) {}

  @Get('profile')
  @UseGuards(JwtGuard, RolesGuard)
  @Roles(
    'ADMIN',
    'MANAGER',
    'TELLER',
    'CUSTOMER',
    'AUDITOR',
  )
  getProfile(@Request() req: ExpressRequest) {
    return this.usersService.getProfile((req.user as any).sub);
  }

  @Patch('profile')
  @UseGuards(JwtGuard, RolesGuard)
  @Roles(
    'ADMIN',
    'MANAGER',
    'TELLER',
    'CUSTOMER',
    'AUDITOR',
  )
  updateProfile(
    @Request() req: ExpressRequest,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(
      (req.user as any).sub,
      dto,
    );
  }
}
