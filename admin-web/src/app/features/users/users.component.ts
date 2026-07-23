import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule, MatCardModule, MatTableModule,
    MatButtonModule, MatIconModule, MatChipsModule, MatInputModule, MatFormFieldModule],
  template: `
    <div class="page">
      <h1>Gestion des utilisateurs</h1>

      <mat-form-field appearance="outline" class="search">
        <mat-label>Rechercher</mat-label>
        <input matInput [(ngModel)]="search" placeholder="Nom ou numéro...">
        <mat-icon matSuffix>search</mat-icon>
      </mat-form-field>

      <mat-card>
        <mat-card-content>
          <table mat-table [dataSource]="filteredUsers" class="full-width">

            <ng-container matColumnDef="name">
              <th mat-header-cell *matHeaderCellDef>Nom</th>
              <td mat-cell *matCellDef="let u">
                {{ u.firstName }} {{ u.lastName }}
              </td>
            </ng-container>

            <ng-container matColumnDef="phone">
              <th mat-header-cell *matHeaderCellDef>Téléphone</th>
              <td mat-cell *matCellDef="let u">{{ u.phoneNumber }}</td>
            </ng-container>

            <ng-container matColumnDef="role">
              <th mat-header-cell *matHeaderCellDef>Rôle</th>
              <td mat-cell *matCellDef="let u">
                <mat-chip [color]="u.role === 'superadmin' ? 'warn' : 'primary'" highlighted>
                  {{ u.role }}
                </mat-chip>
              </td>
            </ng-container>

            <ng-container matColumnDef="status">
              <th mat-header-cell *matHeaderCellDef>Statut</th>
              <td mat-cell *matCellDef="let u">
                <span [class]="u.accountStatus === 'active' ? 'active' : 'deleted'">
                  {{ u.accountStatus }}
                </span>
              </td>
            </ng-container>

            <ng-container matColumnDef="actions">
              <th mat-header-cell *matHeaderCellDef>Actions</th>
              <td mat-cell *matCellDef="let u">
                <button mat-icon-button color="warn"
                  [disabled]="u.role === 'superadmin'"
                  (click)="confirmDelete(u)"
                  title="Supprimer le compte">
                  <mat-icon>delete</mat-icon>
                </button>
              </td>
            </ng-container>

            <tr mat-header-row *matHeaderRowDef="columns"></tr>
            <tr mat-row *matRowDef="let row; columns: columns;"></tr>
          </table>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .page { padding:24px; }
    h1 { margin:0 0 16px; font-size:24px; }
    .search { width:100%; margin-bottom:16px; }
    .full-width { width:100%; }
    .active { color:#006B3C; font-weight:500; }
    .deleted { color:#c62828; font-weight:500; }
  `],
})
export class UsersComponent {
  private adminService = inject(AdminService);

  columns = ['name', 'phone', 'role', 'status', 'actions'];
  search = '';
  allUsers: any[] = [];
  get filteredUsers() {
    if (!this.search) return this.allUsers;
    const s = this.search.toLowerCase();
    return this.allUsers.filter(u =>
      `${u.firstName} ${u.lastName}`.toLowerCase().includes(s) ||
      (u.phoneNumber || '').includes(s)
    );
  }

  constructor() {
    this.adminService.getUsers().subscribe(users => this.allUsers = users);
  }

  confirmDelete(user: any) {
    if (confirm(`Supprimer le compte de ${user.firstName} ${user.lastName} ?`)) {
      // Sera exécuté via Cloud Function quand Blaze sera activé
      alert('Action disponible après activation du plan Blaze (Cloud Functions requises).');
    }
  }
}
