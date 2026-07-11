import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';

import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';

import { JwtGuard } from '../auth/guards/jwt.guard';

import { AccountService } from './account.service';
import { CreateAccountDto } from './dto/create-account.dto';

@ApiTags('Accounts')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtGuard)
@Controller('accounts')
export class AccountController {
  constructor(
    private readonly accountService: AccountService,
  ) {}

  @Post()
  @ApiOperation({
    summary: 'Create Bank Account',
  })
  create(
    @Body() dto: CreateAccountDto,
  ) {
    return this.accountService.create(dto);
  }

  @Get()
  @ApiOperation({
    summary: 'Get All Accounts',
  })
  findAll() {
    return this.accountService.findAll();
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get Account By ID',
  })
  findOne(
    @Param('id') id: string,
  ) {
    return this.accountService.findOne(id);
  }
}