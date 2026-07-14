import { RoleType } from '@prisma/client';

export interface JwtPayload {
  sub: string;
  email: string;
  role: RoleType;
}