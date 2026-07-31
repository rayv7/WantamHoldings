import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';

import { RoleType } from '@prisma/client';

import { JwtGuard } from '../auth/guards/jwt.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

import { AccountService } from './account.service';

import { CreateAccountDto } from './dto/create-account.dto';
import { UpdateAccountDto } from './dto/update-account.dto';
import { QueryAccountDto } from './dto/query-account.dto';

@ApiTags('Accounts')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtGuard, RolesGuard)
@Controller('accounts')
export class AccountController {
  constructor(
    private readonly accountService: AccountService,
  ) {}

  /*
  |--------------------------------------------------------------------------
  | Create Account
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
  )
  @Post()
  @ApiOperation({
    summary: 'Create a new bank account',
  })
  create(
    @Body() dto: CreateAccountDto,
  ) {
    return this.accountService.create(dto);
  }

  /*
  |--------------------------------------------------------------------------
  | Get All Accounts
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.AUDITOR,
  )
  @Get()
  @ApiOperation({
    summary:
      'Get all accounts with pagination and filtering',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    example: 1,
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    example: 10,
  })
  @ApiQuery({
    name: 'search',
    required: false,
  })
  @ApiQuery({
    name: 'status',
    required: false,
  })
  @ApiQuery({
    name: 'accountType',
    required: false,
  })
  @ApiQuery({
    name: 'customerId',
    required: false,
  })
  findAll(
    @Query() query: QueryAccountDto,
  ) {
    return this.accountService.findAll(query);
  }

  /*
  |--------------------------------------------------------------------------
  | Customer Accounts
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.CUSTOMER,
    RoleType.AUDITOR,
  )
  @Get('customer/:customerId')
  @ApiOperation({
    summary:
      'Get all accounts belonging to a customer',
  })
  findCustomerAccounts(
    @Param('customerId')
    customerId: string,
  ) {
    return this.accountService.findCustomerAccounts(
      customerId,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Find By Account Number
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.CUSTOMER,
    RoleType.AUDITOR,
  )
  @Get('number/:accountNumber')
  @ApiOperation({
    summary:
      'Find account using account number',
  })
  findByAccountNumber(
    @Param('accountNumber')
    accountNumber: string,
  ) {
    return this.accountService.findByAccountNumber(
      accountNumber,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Account Balance
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.CUSTOMER,
    RoleType.AUDITOR,
  )
  @Get(':accountNumber/balance')
  @ApiOperation({
    summary:
      'Get account balance',
  })
  getBalance(
    @Param('accountNumber')
    accountNumber: string,
  ) {
    return this.accountService.getBalance(
      accountNumber,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Find By ID
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.AUDITOR,
  )
  @Get(':id')
  @ApiOperation({
    summary:
      'Get account by ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Account ID',
  })
  findOne(
    @Param('id')
    id: string,
  ) {
    return this.accountService.findOne(id);
  }

  /*
  |--------------------------------------------------------------------------
  | Update Account
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Patch(':id')
  @ApiOperation({
    summary:
      'Update account',
  })
  update(
    @Param('id')
    id: string,

    @Body()
    dto: UpdateAccountDto,
  ) {
    return this.accountService.update(
      id,
      dto,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Freeze Account
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Patch(':id/freeze')
  @ApiOperation({
    summary:
      'Freeze account',
  })
  freeze(
    @Param('id')
    id: string,
  ) {
    return this.accountService.freezeAccount(
      id,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Activate Account
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Patch(':id/activate')
  @ApiOperation({
    summary:
      'Activate account',
  })
  activate(
    @Param('id')
    id: string,
  ) {
    return this.accountService.activateAccount(
      id,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Close Account
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Patch(':id/close')
  @ApiOperation({
    summary:
      'Close account',
  })
  close(
    @Param('id')
    id: string,
  ) {
    return this.accountService.closeAccount(
      id,
    );
  }
}