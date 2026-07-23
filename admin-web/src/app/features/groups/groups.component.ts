import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatChipsModule } from '@angular/material/chips';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDialogModule, MatDialog } from '@angular/material/dialog';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-groups',
  standalone: true,
  imports: [
    CommonModule, FormsModule, MatCardModule, MatTableModule, MatButtonModule,
    MatIconModule, MatSlideToggleModule, MatChipsModule, MatInputModule,
    MatFormFieldModule, MatDialogModule, MatSnackBarModule
  ],
  template: `
    <div class="page">
      <div class="page-header">
        <h1>Gestion des groupes</h1>
        <button mat-raised-button color="primary" (click)="showForm.set(!showForm())">
          <mat-icon>{{ showForm() ? 'close' : 'add' }}</mat-icon>
          {{ showForm() ? 'Annuler' : 'Nouveau groupe' }}
        </button>
      </div>

      @if (showForm()) {
        <mat-card class="form-card">
          <mat-card-content>
            <h2>Créer un groupe de discussion</h2>
            <div class="form-row">
              <mat-form-field appearance="outline" class="flex-1">
                <mat-label>Nom du groupe</mat-label>
                <input matInput [(ngModel)]="newName" placeholder="Ex: Actualités Ouaga" />
              </mat-form-field>
              <mat-form-field appearance="outline" class="flex-2">
                <mat-label>Description</mat-label>
                <input matInput [(ngModel)]="newDesc" placeholder="Description courte..." />
              </mat-form-field>
              <button mat-raised-button color="primary" (click)="createGroup()"
                [disabled]="!newName.trim() || creating()">
                <mat-icon>check</mat-icon>
                {{ creating() ? 'Création...' : 'Créer' }}
              </button>
            </div>
          </mat-card-content>
        </mat-card>
      }

      <mat-card>
        <mat-card-content>
          <table mat-table [dataSource]="(groups$ | async) ?? []" class="full-width">

            <ng-container matColumnDef="name">
              <th mat-header-cell *matHeaderCellDef>Nom</th>
              <td mat-cell *matCellDef="let g">
                <strong>{{ g.name }}</strong>
                <div class="desc">{{ g.description }}</div>
              </td>
            </ng-container>

            <ng-container matColumnDef="members">
              <th mat-header-cell *matHeaderCellDef>Membres</th>
              <td mat-cell *matCellDef="let g">{{ g.membersCount ?? 0 }}</td>
            </ng-container>

            <ng-container matColumnDef="writing">
              <th mat-header-cell *matHeaderCellDef>Écriture</th>
              <td mat-cell *matCellDef="let g">
                <mat-slide-toggle
                  [checked]="g.writingEnabled"
                  (change)="toggleWriting(g.id, $event.checked)"
                  color="primary">
                  {{ g.writingEnabled ? 'Active' : 'Désactivée' }}
                </mat-slide-toggle>
              </td>
            </ng-container>

            <ng-container matColumnDef="pinned">
              <th mat-header-cell *matHeaderCellDef>Épinglés</th>
              <td mat-cell *matCellDef="let g">
                <mat-chip>{{ g.pinnedMessageIds?.length || 0 }}</mat-chip>
              </td>
            </ng-container>

            <ng-container matColumnDef="actions">
              <th mat-header-cell *matHeaderCellDef>Actions</th>
              <td mat-cell *matCellDef="let g">
                <button mat-icon-button color="warn" (click)="deleteGroup(g.id, g.name)"
                  matTooltip="Supprimer le groupe">
                  <mat-icon>delete</mat-icon>
                </button>
              </td>
            </ng-container>

            <tr mat-header-row *matHeaderRowDef="columns"></tr>
            <tr mat-row *matRowDef="let row; columns: columns;"></tr>
          </table>

          @if (!(groups$ | async)?.length) {
            <p class="empty">Aucun groupe. Créez-en un ci-dessus.</p>
          }
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: [`
    .page { padding:24px; }
    .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
    h1 { margin:0; font-size:24px; }
    h2 { margin:0 0 16px; font-size:18px; }
    .full-width { width:100%; }
    .desc { font-size:12px; color:#757575; }
    .form-card { margin-bottom:24px; }
    .form-row { display:flex; gap:16px; align-items:center; flex-wrap:wrap; }
    .flex-1 { flex:1; min-width:180px; }
    .flex-2 { flex:2; min-width:220px; }
    .empty { text-align:center; color:#757575; padding:24px; }
  `],
})
export class GroupsComponent {
  private adminService = inject(AdminService);
  private snack = inject(MatSnackBar);

  columns = ['name', 'members', 'writing', 'pinned', 'actions'];
  groups$ = this.adminService.getGroups();

  showForm = signal(false);
  creating = signal(false);
  newName = '';
  newDesc = '';

  createGroup() {
    if (!this.newName.trim()) return;
    this.creating.set(true);
    this.adminService.createGroup(this.newName.trim(), this.newDesc.trim()).subscribe({
      next: () => {
        this.snack.open(`Groupe "${this.newName}" créé !`, 'OK', { duration: 3000 });
        this.newName = '';
        this.newDesc = '';
        this.creating.set(false);
        this.showForm.set(false);
      },
      error: () => {
        this.snack.open('Erreur lors de la création', 'OK', { duration: 3000 });
        this.creating.set(false);
      }
    });
  }

  toggleWriting(groupId: string, enabled: boolean) {
    this.adminService.toggleGroupWriting(groupId, enabled).subscribe();
  }

  deleteGroup(groupId: string, name: string) {
    if (!confirm(`Supprimer le groupe "${name}" ? Cette action est irréversible.`)) return;
    this.adminService.deleteGroup(groupId).subscribe({
      next: () => this.snack.open(`Groupe supprimé`, 'OK', { duration: 3000 }),
      error: () => this.snack.open('Erreur suppression', 'OK', { duration: 3000 }),
    });
  }
}
