import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatIconModule } from '@angular/material/icon';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, MatCardModule, MatButtonModule,
    MatInputModule, MatFormFieldModule, MatProgressSpinnerModule, MatIconModule],
  template: `
    <div class="login-container">
      <mat-card class="login-card">
        <mat-card-header>
          <mat-card-title>Unité 226</mat-card-title>
          <mat-card-subtitle>Panel d'administration</mat-card-subtitle>
        </mat-card-header>
        <mat-card-content>
          <mat-form-field appearance="outline" class="full-width">
            <mat-label>Email</mat-label>
            <input matInput type="email" [(ngModel)]="email" placeholder="admin@unite226.com">
            <mat-icon matSuffix>email</mat-icon>
          </mat-form-field>
          <mat-form-field appearance="outline" class="full-width">
            <mat-label>Mot de passe</mat-label>
            <input matInput [type]="hidePassword ? 'password' : 'text'" [(ngModel)]="password">
            <button mat-icon-button matSuffix (click)="hidePassword = !hidePassword">
              <mat-icon>{{ hidePassword ? 'visibility_off' : 'visibility' }}</mat-icon>
            </button>
          </mat-form-field>
          @if (errorMessage) {
            <p class="error">{{ errorMessage }}</p>
          }
        </mat-card-content>
        <mat-card-actions>
          <button mat-raised-button color="primary" class="full-width"
            [disabled]="loading" (click)="login()">
            @if (loading) {
              <mat-spinner diameter="20"></mat-spinner>
            } @else {
              Se connecter
            }
          </button>
        </mat-card-actions>
      </mat-card>
    </div>
  `,
  styles: [`
    .login-container { display:flex; justify-content:center; align-items:center; height:100vh; background:#f5f5f5; }
    .login-card { width:400px; padding:24px; }
    .full-width { width:100%; margin-bottom:12px; }
    .error { color:red; font-size:13px; margin-top:-8px; }
    mat-card-actions { padding:0 16px 16px; }
  `],
})
export class LoginComponent {
  private adminService = inject(AdminService);
  private router = inject(Router);

  email = '';
  password = '';
  loading = false;
  hidePassword = true;
  errorMessage = '';

  async login() {
    if (!this.email || !this.password) return;
    this.loading = true;
    this.errorMessage = '';
    try {
      const result = await this.adminService.login(this.email, this.password);
      console.log('Login OK', result.user?.uid);
      await this.router.navigate(['/dashboard']);
    } catch (e: any) {
      console.error('Login error', e?.code, e?.message);
      this.errorMessage = e?.message || 'Email ou mot de passe incorrect';
    } finally {
      this.loading = false;
    }
  }
}
