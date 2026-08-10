import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { CustomerModule } from './customer/customer.module';
import { AccountModule } from './account/account.module';
import { TransactionModule } from './transaction/transaction.module';
import { UssdModule } from './ussd/ussd.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    PrismaModule,
    AuthModule,
    UsersModule,
    CustomerModule,
    AccountModule,
    TransactionModule,
    UssdModule,
  ],

  controllers: [AppController],

  providers: [AppService],
})
export class AppModule {}