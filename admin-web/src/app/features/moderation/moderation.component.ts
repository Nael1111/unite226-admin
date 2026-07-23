import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTabsModule } from '@angular/material/tabs';
import { MatTooltipModule } from '@angular/material/tooltip';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-moderation',
  standalone: true,
  imports: [
    CommonModule, FormsModule, MatCardModule, MatTableModule, MatButtonModule,
    MatIconModule, MatChipsModule, MatInputModule, MatFormFieldModule,
    MatSelectModule, MatSnackBarModule, MatTabsModule, MatTooltipModule
  ],
  template: `
    <div class="page">
      <h1>Modération</h1>

      <mat-tab-group>

        <!-- TAB 1 : Utilisateurs -->
        <mat-tab label="Utilisateurs">
          <div class="tab-content">
            <mat-card>
              <mat-card-content>
                <table mat-table [dataSource]="(users$ | async) ?? []" class="full-width">

                  <ng-container matColumnDef="phone">
                    <th mat-header-cell *matHeaderCellDef>Téléphone</th>
                    <td mat-cell *matCellDef="let u">{{ u.phoneNumber ?? u.phone ?? '—' }}</td>
                  </ng-container>

                  <ng-container matColumnDef="name">
                    <th mat-header-cell *matHeaderCellDef>Nom</th>
                    <td mat-cell *matCellDef="let u">{{ u.displayName ?? u.name ?? '—' }}</td>
                  </ng-container>

                  <ng-container matColumnDef="status">
                    <th mat-header-cell *matHeaderCellDef>Statut</th>
                    <td mat-cell *matCellDef="let u">
                      <mat-chip [color]="u.banned ? 'warn' : 'primary'" highlighted>
                        {{ u.banned ? 'Banni' : 'Actif' }}
                      </mat-chip>
                    </td>
                  </ng-container>

                  <ng-container matColumnDef="actions">
                    <th mat-header-cell *matHeaderCellDef>Actions</th>
                    <td mat-cell *matCellDef="let u">
                      <button mat-icon-button [color]="u.banned ? 'primary' : 'warn'"
                        (click)="toggleBan(u.id, u.banned, u.displayName ?? u.phone)"
                        [matTooltip]="u.banned ? 'Débannir' : 'Bannir'">
                        <mat-icon>{{ u.banned ? 'lock_open' : 'block' }}</mat-icon>
                      </button>
                    </td>
                  </ng-container>

                  <tr mat-header-row *matHeaderRowDef="userColumns"></tr>
                  <tr mat-row *matRowDef="let row; columns: userColumns;"></tr>
                </table>
                @if (!(users$ | async)?.length) {
                  <p class="empty">Aucun utilisateur.</p>
                }
              </mat-card-content>
            </mat-card>
          </div>
        </mat-tab>

        <!-- TAB 2 : Messages -->
        <mat-tab label="Messages par groupe">
          <div class="tab-content">
            <mat-card class="select-card">
              <mat-card-content>
                <mat-form-field appearance="outline">
                  <mat-label>Sélectionner un groupe</mat-label>
                  <mat-select [(ngModel)]="selectedGroupId" (ngModelChange)="loadMessages($event)">
                    @for (g of groups(); track g.id) {
                      <mat-option [value]="g.id">{{ g.name }}</mat-option>
                    }
                  </mat-select>
                </mat-form-field>
              </mat-card-content>
            </mat-card>

            @if (selectedGroupId) {
              <mat-card>
                <mat-card-content>
                  <table mat-table [dataSource]="messages()" class="full-width">

                    <ng-container matColumnDef="sender">
                      <th mat-header-cell *matHeaderCellDef>Expéditeur</th>
                      <td mat-cell *matCellDef="let m">{{ m.senderName ?? m.senderId?.slice(0,8) }}...</td>
                    </ng-container>

                    <ng-container matColumnDef="content">
                      <th mat-header-cell *matHeaderCellDef>Contenu</th>
                      <td mat-cell *matCellDef="let m">
                        {{ m.text ?? m.content ?? '[média]' | slice:0:80 }}
                      </td>
                    </ng-container>

                    <ng-container matColumnDef="date">
                      <th mat-header-cell *matHeaderCellDef>Date</th>
                      <td mat-cell *matCellDef="let m">
                        {{ m.createdAt?.toDate() | date:'dd/MM HH:mm' }}
                      </td>
                    </ng-container>

                    <ng-container matColumnDef="actions">
                      <th mat-header-cell *matHeaderCellDef>Actions</th>
                      <td mat-cell *matCellDef="let m">
                        <button mat-icon-button color="warn"
                          (click)="deleteMessage(m.id)"
                          matTooltip="Supprimer ce message">
                          <mat-icon>delete</mat-icon>
                        </button>
                      </td>
                    </ng-container>

                    <tr mat-header-row *matHeaderRowDef="msgColumns"></tr>
                    <tr mat-row *matRowDef="let row; columns: msgColumns;"></tr>
                  </table>
                  @if (!messages().length) {
                    <p class="empty">Aucun message dans ce groupe.</p>
                  }
                </mat-card-content>
              </mat-card>
            }
          </div>
        </mat-tab>

        <!-- TAB 3 : Journal -->
        <mat-tab label="Journal des actions">
          <div class="tab-content">
            <mat-card>
              <mat-card-content>
                <table mat-table [dataSource]="(logs$ | async) ?? []" class="full-width">

                  <ng-container matColumnDef="action">
                    <th mat-header-cell *matHeaderCellDef>Action</th>
                    <td mat-cell *matCellDef="let log">
                      <mat-chip>{{ log.action }}</mat-chip>
                    </td>
                  </ng-container>

                  <ng-container matColumnDef="actor">
                    <th mat-header-cell *matHeaderCellDef>Par</th>
                    <td mat-cell *matCellDef="let log">{{ log.actorUid | slice:0:8 }}...</td>
                  </ng-container>

                  <ng-container matColumnDef="target">
                    <th mat-header-cell *matHeaderCellDef>Cible</th>
                    <td mat-cell *matCellDef="let log">{{ log.targetUid | slice:0:8 }}...</td>
                  </ng-container>

                  <ng-container matColumnDef="date">
                    <th mat-header-cell *matHeaderCellDef>Date</th>
                    <td mat-cell *matCellDef="let log">
                      {{ log.timestamp?.toDate() | date:'dd/MM/yyyy HH:mm' }}
                    </td>
                  </ng-container>

                  <tr mat-header-row *matHeaderRowDef="logColumns"></tr>
                  <tr mat-row *matRowDef="let row; columns: logColumns;"></tr>
                </table>
                @if (!(logs$ | async)?.length) {
                  <p class="empty">Aucune action de modération enregistrée.</p>
                }
              </mat-card-content>
            </mat-card>
          </div>
        </mat-tab>

      </mat-tab-group>
    </div>
  `,
  styles: [`
    .page { padding:24px; }
    h1 { margin:0 0 24px; font-size:24px; }
    .tab-content { padding:24px 0; }
    .select-card { margin-bottom:16px; }
    .full-width { width:100%; }
    .empty { text-align:center; color:#757575; padding:24px; }
    mat-form-field { min-width:280px; }
  `],
})
export class ModerationComponent implements OnInit {
  private adminService = inject(AdminService);
  private snack = inject(MatSnackBar);

  userColumns = ['phone', 'name', 'status', 'actions'];
  msgColumns = ['sender', 'content', 'date', 'actions'];
  logColumns = ['action', 'actor', 'target', 'date'];

  users$ = this.adminService.getUsers();
  logs$ = this.adminService.getModerationLogs();

  groups = signal<any[]>([]);
  selectedGroupId = '';
  messages = signal<any[]>([]);

  ngOnInit() {
    this.adminService.getGroups().subscribe(g => this.groups.set(g));
  }

  loadMessages(groupId: string) {
    this.adminService.getMessages(groupId).subscribe(msgs => this.messages.set(msgs));
  }

  toggleBan(uid: string, currentlyBanned: boolean, name: string) {
    const action = currentlyBanned ? 'débannir' : 'bannir';
    if (!confirm(`Voulez-vous ${action} "${name}" ?`)) return;
    this.adminService.banUser(uid, !currentlyBanned).subscribe({
      next: () => {
        this.adminService.logModerationAction(
          currentlyBanned ? 'unban' : 'ban', uid, { name }
        ).subscribe();
        this.snack.open(`Utilisateur ${action}ni`, 'OK', { duration: 3000 });
      },
      error: () => this.snack.open('Erreur', 'OK', { duration: 3000 }),
    });
  }

  deleteMessage(messageId: string) {
    if (!confirm('Supprimer ce message ?')) return;
    this.adminService.deleteMessage(this.selectedGroupId, messageId).subscribe({
      next: () => {
        this.messages.update(msgs => msgs.filter(m => m.id !== messageId));
        this.snack.open('Message supprimé', 'OK', { duration: 3000 });
      },
      error: () => this.snack.open('Erreur suppression', 'OK', { duration: 3000 }),
    });
  }
}
