import {
  Controller,
  Get,
  Request,
  UseGuards,
} from '@nestjs/common';

import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';

import { JwtGuard } from '../auth/guards/jwt.guard';

@ApiTags('Users')
@ApiBearerAuth('JWT-auth')   // <- Apply to the whole controller
@Controller('users')
export class UsersController {
  @Get('profile')
  @UseGuards(JwtGuard)
  @ApiOperation({
    summary: 'Get the authenticated user profile',
  })
  @ApiResponse({
    status: 200,
    description: 'Returns the authenticated user.',
  })
  getProfile(@Request() req) {
    return req.user;
  }
}