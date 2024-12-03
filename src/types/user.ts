export type UserRole = 'admin' | 'general_coordinator' | 'subnet_coordinator' | 'manager' | 'guest';

export interface User {
  id: string;
  name: string;
  lastName: string;
  medusaCode: string;
  email: string;
  phone?: string;
  center: string;
  network: string;
  role: UserRole;
  imageUrl?: string;
  passwordChangeRequired?: boolean;
}

export interface UserFormData extends Omit<User, 'id'> {
  password?: string;
}