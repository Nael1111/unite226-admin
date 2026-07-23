import { Routes } from '@angular/router';
import { superadminGuard } from './core/guards/superadmin.guard';

export const routes: Routes = [
  {
    path: 'auth',
    children: [
      {
        path: 'login',
        loadComponent: () =>
          import('./features/auth/login.component').then((m) => m.LoginComponent),
      },
    ],
  },
  {
    path: '',
    canActivate: [superadminGuard],
    loadComponent: () =>
      import('./shared/components/layout.component').then((m) => m.LayoutComponent),
    children: [
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then((m) => m.DashboardComponent),
      },
      {
        path: 'groups',
        loadComponent: () =>
          import('./features/groups/groups.component').then((m) => m.GroupsComponent),
      },
      {
        path: 'users',
        loadComponent: () =>
          import('./features/users/users.component').then((m) => m.UsersComponent),
      },
      {
        path: 'moderation',
        loadComponent: () =>
          import('./features/moderation/moderation.component').then((m) => m.ModerationComponent),
      },
      {
        path: 'validations',
        loadComponent: () =>
          import('./features/validations/validations.component').then((m) => m.ValidationsComponent),
      },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },
  { path: '**', redirectTo: 'dashboard' },
];
