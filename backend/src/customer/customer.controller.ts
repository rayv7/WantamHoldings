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
  ApiNotFoundResponse,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';

import { RoleType } from '@prisma/client';

import { CustomerService } from './customer.service';

import { CreateCustomerDto } from './dto/create-customer.dto';
import { QueryCustomerDto } from './dto/query-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';

import { JwtGuard } from '../auth/guards/jwt.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('Customers')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtGuard, RolesGuard)
@Controller('customers')
export class CustomerController {
  constructor(
    private readonly customerService: CustomerService,
  ) {}

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
  )
  @Post()
  @ApiOperation({
    summary: 'Create a new customer',
  })
  create(@Body() dto: CreateCustomerDto) {
    return this.customerService.create(dto);
  }

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.AUDITOR,
  )
  @Get()
  @ApiOperation({
    summary: 'Get all customers',
  })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'status', required: false })
  findAll(@Query() query: QueryCustomerDto) {
    return this.customerService.findAll(query);
  }

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
    RoleType.TELLER,
    RoleType.AUDITOR,
  )
  @Get(':id')
  @ApiOperation({
    summary: 'Get customer by ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Customer ID',
  })
  @ApiNotFoundResponse({
    description: 'Customer not found',
  })
  findOne(@Param('id') id: string) {
    return this.customerService.findOne(id);
  }

  @Roles(
    RoleType.ADMIN,
    RoleType.MANAGER,
  )
  @Patch(':id')
  @ApiOperation({
    summary: 'Update customer',
  })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateCustomerDto,
  ) {
    return this.customerService.update(id, dto);
  }
}