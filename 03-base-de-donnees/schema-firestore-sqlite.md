# Schéma de données

## 1. Cloud Firestore (source de vérité)

### Collection `users`
```
users/{userId}
  - phoneNumber: string        // format +226XXXXXXXX
  - firstName: string
  - lastName: string
  - idCardFrontUrl: string     // Storage, accès restreint
  - idCardBackUrl: string      // Storage, accès restreint
  - profilePhotoUrl: string
  - role: "user" | "superadmin"   // le rôle "admin" est porté au niveau du groupe,
                                    // pas au niveau global (voir groupMembers)
  - accountStatus: "active" | "deleted"
  - createdAt: timestamp
```

### Collection `groups`
```
groups/{groupId}
  - name: string
  - description: string
  - createdBy: userId            // toujours un superadmin
  - createdAt: timestamp
  - writingEnabled: boolean       // true = tout le monde peut écrire, false = lecture seule
  - membersCount: number          // dénormalisé pour affichage rapide, pas de limite
  - pinnedMessageIds: array<string>
```

### Sous-collection `groups/{groupId}/members`
```
groups/{groupId}/members/{userId}
  - role: "member" | "groupAdmin"
  - isAnonymous: boolean
  - anonymousLabel: string        // ex "Inconnu 3", généré si isAnonymous = true
  - anonymousColor: string        // code couleur hex, généré si isAnonymous = true
  - restricted: boolean           // restreint par un admin/superadmin
  - joinedAt: timestamp
```

### Sous-collection `groups/{groupId}/messages`
```
groups/{groupId}/messages/{messageId}
  - senderId: userId
  - displayName: string           // nom réel OU "Inconnu N" selon isAnonymous au moment
                                    // de l'envoi (dénormalisé pour ne pas recalculer
                                    // l'historique si l'utilisateur désactive plus tard
                                    // son mode inconnu)
  - displayColor: string          // couleur au moment de l'envoi si anonyme
  - type: "text" | "voice" | "video" | "image" | "link"
  - content: string               // texte, ou URL Storage pour média, ou URL pour lien
  - replyToMessageId: string|null // référence pour la fonction "répondre/mentionner"
  - isPinned: boolean
  - createdAt: timestamp
```

### Compteur d'anonymes par groupe
Pour garantir des labels `Inconnu 1`, `Inconnu 2`, etc. sans collision, prévoir un compteur
atomique par groupe, par exemple :
```
groups/{groupId}/meta/anonymousCounter
  - lastNumber: number
```
Incrémenté via une transaction Firestore (ou Cloud Function) à chaque nouvelle
activation du mode inconnu dans ce groupe.

## 2. SQLite (cache local mobile uniquement)

Rôle : miroir en lecture rapide des données Firestore déjà synchronisées, pour un
affichage instantané et un usage hors-ligne partiel. Ne pas dupliquer les règles de
permission ici — SQLite est un cache, pas une source d'autorité.

```sql
CREATE TABLE cached_groups (
  group_id TEXT PRIMARY KEY,
  name TEXT,
  description TEXT,
  writing_enabled INTEGER,
  members_count INTEGER,
  last_synced_at INTEGER
);

CREATE TABLE cached_messages (
  message_id TEXT PRIMARY KEY,
  group_id TEXT,
  sender_id TEXT,
  display_name TEXT,
  display_color TEXT,
  type TEXT,
  content TEXT,
  reply_to_message_id TEXT,
  is_pinned INTEGER,
  created_at INTEGER,
  FOREIGN KEY (group_id) REFERENCES cached_groups(group_id)
);

CREATE INDEX idx_messages_group ON cached_messages(group_id, created_at);
```

## 3. Règles de sécurité Firestore — principes directeurs

À implémenter précisément en phase de développement, mais les principes non négociables :

- `users/{userId}` : lecture des champs publics (nom, photo) ouverte aux membres
  authentifiés ; lecture des champs `idCardFrontUrl`/`idCardBackUrl` réservée au
  document lui-même et au `superadmin` ; écriture du champ `role` interdite au client,
  uniquement via Cloud Function
- `groups/{groupId}` : création réservée aux comptes `role == "superadmin"`
- `groups/{groupId}/members/{userId}` : un utilisateur peut modifier `isAnonymous` sur
  son propre document ; ne peut jamais modifier `role` ou `restricted` sur lui-même
- `groups/{groupId}/messages` : écriture autorisée seulement si `writingEnabled == true`
  sur le groupe ET si l'utilisateur n'est pas `restricted`
