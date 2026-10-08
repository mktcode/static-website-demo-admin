# DynaMesh Redaktion

Standalone [Sveltia CMS](https://sveltiacms.app/) für `mktcode/static-website-demo`, Zielbranch `main`. Dieses Repository enthält ausschließlich das Redaktionssystem; Inhalte werden im **Website-Repository** gespeichert, nicht hier.

## Deployment mit Dokploy

1. Dateien in `mktcode/static-website-demo-admin` pushen.
2. In Dokploy eine **Application** anlegen, GitHub-Repository `mktcode/static-website-demo-admin` und dessen Deployment-Branch wählen.
3. Build Type **Dockerfile**, Dockerfile-Pfad `Dockerfile`, Build Context `.` (Repository-Wurzel).
4. Domain `admin.dyna-mesh.com` auf **Container-Port 80** konfigurieren; DNS auf den Dokploy-Server richten und HTTPS aktivieren.
5. Deploy starten. Keine Volumes, Datenbank oder Umgebungsvariablen erforderlich. CMS und Konfiguration werden im Image ausgeliefert.

Der CMS-Release ist im Dockerfile auf `0.231.0` fixiert und wird beim Build heruntergeladen. Updates bewusst über `SVELTIA_CMS_VERSION` vornehmen und erneut deployen. Die Base-Image-Tags erhalten weiterhin Patch-Updates.

## GitHub-Anmeldung

Auf `https://admin.dyna-mesh.com/` **Sign In with Token** wählen. Jeder Benutzer benötigt einen eigenen GitHub-Account mit Schreibzugriff auf `mktcode/static-website-demo`.

Für einen **fine-grained Personal Access Token** nur das Website-Repository auswählen:

- **Contents: Read and write**
- **Pull requests: Read and write** (für Editorial Workflow zwingend)
- **Metadata: Read-only** (automatisch)

Der CMS-Anmeldedialog bietet auch einen Link zur Token-Erstellung. Tokens mit Ablaufdatum verwenden. Sveltia speichert den Token im Browser-Local-Storage; nur auf vertrauenswürdigen Geräten anmelden und anschließend abmelden. **Keinen Token in Git, YAML, Docker-Build-Args oder Dokploy hinterlegen.**

Für komfortablen GitHub-OAuth-Login ist zusätzlich ein OAuth-Client nötig, z. B. [Sveltia CMS Authenticator](https://github.com/sveltia/sveltia-cms-auth). Dieser ist hier nicht enthalten. Nach dessen Einrichtung wird `backend.base_url` in `public/config.yml` ergänzt; das OAuth-Secret gehört ausschließlich in den Authenticator.

## Redaktion und Veröffentlichung

1. **Seiten → Engineering Principles** öffnen und Markdown bearbeiten.
2. Speichern legt einen CMS-Branch und einen Pull Request gegen `main` an; die Live-Website bleibt unverändert.
3. Entwurf zur Prüfung senden (**In Review**), prüfen und auf **Ready** setzen.
4. **Publish** merged den Pull Request nach `main`; der vorhandene GitHub-Pages-Workflow baut und veröffentlicht die Website.

Die Datei `content/engineering-principles.md` bleibt Markdown **ohne Front Matter** (`format: raw`). Die HTML-Vorlage und der Website-Build müssen nicht verändert werden. Weitere vorhandene Inhaltsdateien können unter `collections[].files` ergänzt werden.

**Review verbindlich erzwingen:** CMS-Status allein ist keine Berechtigungsgrenze. In GitHub für `main` eine Branch Protection/Ruleset mit Pull-Request-Pflicht und erforderlichen Reviews konfigurieren. Merge-/Squash-Berechtigungen und etwaige Bypass-Rechte prüfen. Squash-Merges müssen im Website-Repository erlaubt sein.

### Bilder

`content/media` ist die Medienablage des Website-Repositories. **Die separate Asset Library schreibt direkt nach `main`, unabhängig vom Editorial Workflow.** Für geprüfte Änderungen Medien innerhalb eines Inhaltsentwurfs hochladen. Bei geschütztem `main` ist die separate Asset Library für Benutzer ohne direkten Push-Zugriff schreibgeschützt.

Die HTML-Vorlage verwendet fest `content/media/hero.jpg`. Ein anderer Dateiname ändert das Hero-Bild nicht. Die Hero-Bildauswahl ist derzeit kein eigenes CMS-Feld, da sie in `index.html` und nicht in einer Inhaltsdatei liegt. Zum geprüften Austausch kann alternativ ein GitHub-Pull-Request verwendet werden.

`site_url`, `display_url` und `public_folder` zeigen auf die aktuell dokumentierte GitHub-Pages-Website. Bei Wechsel auf `https://dyna-mesh.com` die ersten beiden URLs entsprechend ändern und `public_folder: /content/media` setzen.

## Lokal testen

```sh
docker build -t dynamesh-admin .
docker run --rm -p 8080:80 dynamesh-admin
# http://localhost:8080
```

Der lokale Container verwendet ebenfalls das echte GitHub-Repository. Speichern erzeugt dort echte Branches und Pull Requests.

```sh
curl -f http://localhost:8080/healthz
curl -f http://localhost:8080/config.yml
```

Dokumentation: [Editorial Workflow](https://sveltiacms.app/en/docs/workflows/editorial), [GitHub Backend](https://sveltiacms.app/en/docs/backends/github).
