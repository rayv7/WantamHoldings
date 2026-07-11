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

import { CustomerService } from './customer.service';

import { CreateCustomerDto } from './dto/create-customer.dto';
import { QueryCustomerDto } from './dto/query-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';

import { JwtGuard } from '../auth/guards/jwt.guard';

@ApiTags('Customers')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtGuard)
@Controller('customers')
export class CustomerController {
  constructor(
    private readonly customerService: CustomerService,
  ) {}

  @Post()
  @ApiOperation({
    summary: 'Create a new customer',
  })
  create(
    @Body() dto: CreateCustomerDto,
  ) {
    return this.customerService.create(dto);
  }

  @Get()
  @ApiOperation({
    summary: 'Get all customers',
    description:
      'Returns customers with pagination, search and status filtering.',
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
    example: 'John',
  })
  @ApiQuery({
    name: 'status',
    required: false,
    example: 'ACTIVE',
  })
  findAll(
    @Query() query: QueryCustomerDto,
  ) {
    return this.customerService.findAll(query);
  }

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
  findOne(
    @Param('id') id: string,
  ) {
    return this.customerService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({
    summary: 'Update customer',
  })
  @ApiParam({
    name: 'id',
    description: 'Customer ID',
  })
  @ApiNotFoundResponse({
    description: 'Customer not found',
  })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateCustomerDto,
  ) {
    return this.customerService.update(id, dto);
  }
}