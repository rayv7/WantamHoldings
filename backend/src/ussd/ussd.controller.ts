import { Controller, Post, Body } from '@nestjs/common';
import { UssdService } from './ussd.service';
import { UssdDto } from './ussd.dto';

@Controller('ussd')
export class UssdController {
  constructor(
    private readonly ussdService: UssdService,
  ) {}

  @Post()
  async handleUssd(@Body() body: UssdDto) {
    return this.ussdService.handleUssd(body);
  }
}