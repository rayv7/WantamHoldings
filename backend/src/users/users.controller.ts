import {
  Controller,
  Get,
  Request,
  UseGuards,
} from '@nestjs/common';

import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { JwtGuard } from '../auth/guards/jwt.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('Users')
@ApiBearerAuth('JWT-auth')
@Controller('users')
export class UsersController {

  @Get('profile')
  @UseGuards(JwtGuard, RolesGuard)
  @Roles(
    'ADMIN',
    'MANAGER',
    'TELLER',
    'CUSTOMER',
    'AUDITOR',
  )
  getProfile(@Request() req) {
    return req.user;
  }
}