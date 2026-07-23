import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatIconModule],
  template: `
    <div class="page">
      <h1>Tableau de bord</h1>
      <div class="stats-grid">
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon class="stat-icon users">people</mat-icon>
            <div class="stat-value">{{ stats().users }}</div>
            <div class="stat-label">Utilisateurs</div>
          </mat-card-content>
        </mat-card>
        <mat-card class="stat-card">
          <mat-card-content>
            <mat-icon class="stat-icon groups">group</mat-icon>
            <div class="stat-value">{{ stats().groups }}</div>
            <div class="stat-label">Groupes</div>
          </mat-card-content>
        </mat-card>
      </div>

      <h2>Groupes actifs</h2>
      <div class="groups-list">
        @for (group of groups$ | async; track group.id) {
          <mat-card class="group-item">
            <mat-card-content>
              <div class="group-row">
                <div>
                  <strong>{{ group.name }}</strong>
                  <span class="members">{{ group.membersCount ?? 0 }} membres</span>
                </div>
                <span class="badge" [class.disabled]="!group.writingEnabled">
                  {{ group.writingEnabled ? 'Écriture active' : 'Lecture seule' }}
                </span>
              </div>
            </mat-card-content>
          </mat-card>
        } @empty {
          <p style="color:#757575">Aucun groupe créé. Allez dans "Groupes" pour en créer un.</p>
        }
      </div>
    </div>
  `,
  styles: [`
    .page { padding:24px; }
    h1 { margin:0 0 24px; font-size:24px; }
    h2 { margin:24px 0 12px; font-size:18px; }
    .stats-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(180px,1fr)); gap:16px; margin-bottom:8px; }
    .stat-card mat-card-content { display:flex; flex-direction:column; align-items:center; padding:24px 16px; }
    .stat-icon { font-size:40px; width:40px; height:40px; margin-bottom:8px; }
    .stat-icon.users { color:#006B3C; }
    .stat-icon.groups { color:#1565C0; }
    .stat-value { font-size:32px; font-weight:bold; }
    .stat-label { color:#757575; font-size:14px; }
    .group-item { margin-bottom:8px; }
    .group-row { display:flex; justify-content:space-between; align-items:center; }
    .members { color:#757575; font-size:13px; margin-left:8px; }
    .badge { padding:4px 10px; border-radius:12px; font-size:12px; background:#e8f5e9; color:#006B3C; }
    .badge.disabled { background:#fce4ec; color:#c62828; }
  `],
})
export class DashboardComponent implements OnInit {
  private adminService = inject(AdminService);

  stats = signal({ users: 0, groups: 0 });
  groups$ = this.adminService.getGroups();

  async ngOnInit() {
    this.stats.set(await this.adminService.getStats());
    // Rafraîchir les stats quand les groupes changent
    this.groups$.subscribe(groups => {
      this.adminService.getStats().then(s => this.stats.set(s));
    });
  }
}
