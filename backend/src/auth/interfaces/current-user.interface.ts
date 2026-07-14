import { RoleType } from '@prisma/client';

export interface CurrentUser {
  sub: string;

  email: string;

  role: RoleType;
}