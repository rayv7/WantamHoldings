import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { Request as ExpressRequest } from 'express';

import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';

import { RoleType } from '@prisma/client';

import { JwtGuard } from '../auth/guards/jwt.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

import { TransactionService } from './transaction.service';

import { DepositDto } from './dto/deposit.dto';
import { WithdrawDto } from './dto/withdraw.dto';
import { TransferDto } from './dto/transfer.dto';
import { ReverseTransactionDto } from './dto/reverse-transaction.dto';
import { InterestDto } from './dto/interest.dto';
import { ChargeDto } from './dto/charge.dto';
import { StatementDto } from './dto/statement.dto';

@ApiTags('Transactions')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtGuard, RolesGuard)
@Controller('transactions')
export class TransactionController {
  constructor(
    private readonly transactionService: TransactionService,
  ) {}

  /*
  |--------------------------------------------------------------------------
  | Deposit
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
  )
  @Post('deposit')
  @ApiOperation({
    summary: 'Deposit money into an account',
  })
  deposit(
    @Body() dto: DepositDto,
    @Request() req: ExpressRequest,
  ) {
    return this.transactionService.deposit(
      dto,
      req.user,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Withdraw
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
  )
  @Post('withdraw')
  @ApiOperation({
    summary: 'Withdraw money from an account',
  })
  withdraw(
    @Body() dto: WithdrawDto,
    @Request() req: ExpressRequest,
  ) {
    return this.transactionService.withdraw(
      dto,
      req.user,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Transfer
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.CUSTOMER,
  )
  @Post('transfer')
  @ApiOperation({
    summary: 'Transfer money between accounts',
  })
  transfer(
    @Body() dto: TransferDto,
    @Request() req: ExpressRequest,
  ) {
    return this.transactionService.transfer(
      dto,
      req.user,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Reverse Transaction
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Post('reverse')
  @ApiOperation({
    summary: 'Reverse an existing transaction',
  })
  reverse(
    @Body() dto: ReverseTransactionDto,
    @Request() req: ExpressRequest,
  ) {
    return this.transactionService.reverse(
      dto,
      req.user,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Apply Interest
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Post('interest')
  @ApiOperation({
    summary: 'Apply interest to an account',
  })
  applyInterest(
    @Body() dto: InterestDto,
    @Request() req: ExpressRequest,
  ) {
    return this.transactionService.applyInterest(
      dto,
      req.user,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Apply Charges
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Post('charge')
  @ApiOperation({
    summary: 'Apply charges to an account',
  })
  applyCharge(
    @Body() dto: ChargeDto,
    @Request() req: ExpressRequest,
  ) {
    return this.transactionService.applyCharge(
      dto,
      req.user,
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Account Statement
  |--------------------------------------------------------------------------
  */

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.CUSTOMER,
    RoleType.AUDITOR,
  )
  @Get('statement/:accountNumber')
  @ApiOperation({
    summary: 'Generate account statement',
  })
  statement(
    @Param('accountNumber')
    accountNumber: string,

    @Query()
    dto: StatementDto,
  ) {
    return this.transactionService.generateStatement(
      accountNumber,
      dto,
    );
  }
}