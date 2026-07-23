import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [CommonModule, RouterModule, MatSidenavModule, MatToolbarModule,
    MatListModule, MatIconModule, MatButtonModule],
  template: `
    <mat-sidenav-container class="sidenav-container">
      <mat-sidenav mode="side" opened class="sidenav">
        <div class="logo">
          <span class="logo-text">Unité 226</span>
          <span class="logo-sub">Admin</span>
        </div>
        <mat-nav-list>
          @for (item of navItems; track item.route) {
            <a mat-list-item [routerLink]="item.route" routerLinkActive="active-link">
              <mat-icon matListItemIcon>{{ item.icon }}</mat-icon>
              <span matListItemTitle>{{ item.label }}</span>
            </a>
          }
        </mat-nav-list>
        <div class="sidenav-footer">
          <button mat-button (click)="logout()" class="logout-btn">
            <mat-icon>logout</mat-icon> Déconnexion
          </button>
        </div>
      </mat-sidenav>
      <mat-sidenav-content class="main-content">
        <router-outlet></router-outlet>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: [`
    .sidenav-container { height: 100vh; }
    .sidenav { width: 240px; background: #006B3C; color: white; display:flex; flex-direction:column; }
    .logo { padding: 24px 16px 16px; border-bottom: 1px solid rgba(255,255,255,0.2); }
    .logo-text { display:block; font-size:20px; font-weight:bold; color:white; }
    .logo-sub { font-size:12px; color:rgba(255,255,255,0.7); }
    mat-nav-list { flex:1; padding-top:8px; }
    a[mat-list-item] { color: rgba(255,255,255,0.85); border-radius:8px; margin:2px 8px; }
    a[mat-list-item]:hover { background: rgba(255,255,255,0.1); }
    .active-link { background: rgba(255,255,255,0.2) !important; color:white !important; }
    mat-icon { color: rgba(255,255,255,0.85); }
    .sidenav-footer { padding:16px; border-top:1px solid rgba(255,255,255,0.2); }
    .logout-btn { color:rgba(255,255,255,0.7); width:100%; }
    .main-content { background:#f5f5f5; overflow-y:auto; }
  `],
})
export class LayoutComponent {
  private adminService = inject(AdminService);
  private router = inject(Router);

  navItems = [
    { route: '/dashboard', icon: 'dashboard', label: 'Tableau de bord' },
    { route: '/validations', icon: 'how_to_reg', label: 'Validations' },
    { route: '/groups', icon: 'group', label: 'Groupes' },
    { route: '/users', icon: 'people', label: 'Utilisateurs' },
    { route: '/moderation', icon: 'gavel', label: 'Modération' },
  ];

  async logout() {
    await this.adminService.logout();
    this.router.navigate(['/auth/login']);
  }
}
