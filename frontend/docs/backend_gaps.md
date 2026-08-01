# Backend API gaps

The Flutter client only exposes verified NestJS routes. The following requested areas have Prisma models or product requirements but no controller route to safely integrate: refresh tokens, forgot/reset password, onboarding persistence, customer self-service account lookup, users CRUD, roles CRUD, cards, loans, beneficiaries, notifications, audit logs, reports, settings, support, and XAMPP PHP endpoints.

Add documented, authenticated endpoints for these capabilities before they can be surfaced in the app. No mock data or client-invented APIs are used.
