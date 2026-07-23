import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-validations',
  standalone: true,
  imports: [
    CommonModule, MatCardModule, MatButtonModule, MatIconModule,
    MatChipsModule, MatSnackBarModule, MatTooltipModule, MatDialogModule
  ],
  template: `
    <div class="page">
      <h1>Validations de comptes</h1>

      @if (pending().length === 0) {
        <mat-card>
          <mat-card-content class="empty">
            <mat-icon style="font-size:48px;width:48px;height:48px;color:#bdbdbd">check_circle</mat-icon>
            <p>Aucun compte en attente de validation.</p>
          </mat-card-content>
        </mat-card>
      }

      @for (u of pending(); track u.id) {
        <mat-card class="user-card">
          <mat-card-content>
            <div class="user-header">
              <div class="avatar">
                @if (u.profilePhotoUrl) {
                  <img [src]="u.profilePhotoUrl" alt="photo" />
                } @else {
                  <mat-icon>person</mat-icon>
                }
              </div>
              <div class="user-info">
                <strong>{{ u.firstName }} {{ u.lastName }}</strong>
                <span class="email">{{ u.email }}</span>
                <span class="date">Inscrit le {{ u.createdAt?.toDate() | date:'dd/MM/yyyy à HH:mm' }}</span>
              </div>
              <mat-chip color="warn" highlighted>En attente</mat-chip>
            </div>

            <div class="cnib-row">
              <div class="cnib-card">
                <p class="cnib-label">CNIB Recto</p>
                @if (u.cnibFrontUrl) {
                  <a [href]="u.cnibFrontUrl" target="_blank">
                    <img [src]="u.cnibFrontUrl" alt="CNIB recto" class="cnib-img" />
                  </a>
                } @else {
                  <p class="no-doc">Non fourni</p>
                }
              </div>
              <div class="cnib-card">
                <p class="cnib-label">CNIB Verso</p>
                @if (u.cnibBackUrl) {
                  <a [href]="u.cnibBackUrl" target="_blank">
                    <img [src]="u.cnibBackUrl" alt="CNIB verso" class="cnib-img" />
                  </a>
                } @else {
                  <p class="no-doc">Non fourni</p>
                }
              </div>
            </div>

            <div class="actions">
              <button mat-raised-button color="primary" (click)="approve(u.id, u.firstName)"
                [disabled]="processing()">
                <mat-icon>check</mat-icon> Approuver
              </button>
              <button mat-raised-button color="warn" (click)="reject(u.id, u.firstName)"
                [disabled]="processing()">
                <mat-icon>close</mat-icon> Rejeter
              </button>
            </div>
          </mat-card-content>
        </mat-card>
      }
    </div>
  `,
  styles: [`
    .page { padding: 24px; }
    h1 { margin: 0 0 24px; font-size: 24px; }
    .empty { display: flex; flex-direction: column; align-items: center; padding: 48px; color: #757575; }
    .user-card { margin-bottom: 16px; }
    .user-header { display: flex; align-items: center; gap: 16px; margin-bottom: 16px; }
    .avatar { width: 56px; height: 56px; border-radius: 50%; overflow: hidden; background: #e0e0e0;
      display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .avatar img { width: 100%; height: 100%; object-fit: cover; }
    .user-info { display: flex; flex-direction: column; flex: 1; }
    .user-info strong { font-size: 16px; }
    .email { color: #757575; font-size: 13px; }
    .date { color: #9e9e9e; font-size: 12px; }
    .cnib-row { display: flex; gap: 16px; margin-bottom: 16px; }
    .cnib-card { flex: 1; }
    .cnib-label { font-size: 12px; color: #757575; margin: 0 0 4px; font-weight: 500; }
    .cnib-img { width: 100%; max-height: 180px; object-fit: cover; border-radius: 8px;
      border: 1px solid #e0e0e0; cursor: pointer; }
    .no-doc { color: #bdbdbd; font-size: 13px; }
    .actions { display: flex; gap: 12px; }
  `]
})
export class ValidationsComponent implements OnInit {
  private adminService = inject(AdminService);
  private snack = inject(MatSnackBar);

  pending = signal<any[]>([]);
  processing = signal(false);

  ngOnInit() {
    this.adminService.getPendingUsers().subscribe(users => this.pending.set(users));
  }

  approve(uid: string, name: string) {
    if (!confirm(`Approuver le compte de ${name} ?`)) return;
    this.processing.set(true);
    this.adminService.approveUser(uid).subscribe({
      next: () => {
        this.snack.open(`Compte de ${name} approuvé ✓`, 'OK', { duration: 3000 });
        this.processing.set(false);
      },
      error: (e) => {
        this.snack.open('Erreur : ' + e.message, 'OK', { duration: 4000 });
        this.processing.set(false);
      }
    });
  }

  reject(uid: string, name: string) {
    const reason = prompt(`Raison du rejet pour ${name} (optionnel) :`);
    if (reason === null) return; // annulé
    this.processing.set(true);
    this.adminService.rejectUser(uid, reason).subscribe({
      next: () => {
        this.snack.open(`Compte de ${name} rejeté`, 'OK', { duration: 3000 });
        this.processing.set(false);
      },
      error: (e) => {
        this.snack.open('Erreur : ' + e.message, 'OK', { duration: 4000 });
        this.processing.set(false);
      }
    });
  }
}
