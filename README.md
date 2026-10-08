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

1. **Seiten** öffnen, eine vorhandene Seite bearbeiten oder eine neue Seite anlegen. Titel und Markdown-Inhalt pro Sprache (Englisch/Deutsch) eingeben.
2. Speichern legt einen CMS-Branch und einen Pull Request gegen `main` an; die Live-Website bleibt unverändert.
3. Entwurf zur Prüfung senden (**In Review**), prüfen und auf **Ready** setzen.
4. **Publish** merged den Pull Request nach `main`; der vorhandene GitHub-Pages-Workflow baut und veröffentlicht die Website.

Die Folder Collection erlaubt neue Einträge (`create: true`). Übersetzungen liegen in `content/pages/en/<slug>.md` und `content/pages/de/<slug>.md`, jeweils mit YAML Front Matter (`title`) und Markdown-Inhalt. Sveltia verknüpft beide anhand des gleichen Dateinamens. Der Website-Build erzeugt `/en/<slug>/` und `/de/<slug>/`, inklusive Navigation und Sprachwechsel. `index.md` ist die Startseite unter `/en/` bzw. `/de/`; nicht umbenennen. CMS-Löschungen sind deaktiviert, um diese Startseiten zu schützen.

Die alte Datei `content/engineering-principles.md` wird nicht mehr gerendert. Offene PRs für diese Datei müssen geprüft und ihre Änderungen bei Bedarf in die neuen Startseiten übertragen werden. **Zuerst den neuen Website-Build samt Inhaltsdateien deployen, dann das CMS redeployen.**

**Review verbindlich erzwingen:** CMS-Status allein ist keine Berechtigungsgrenze. In GitHub für `main` eine Branch Protection/Ruleset mit Pull-Request-Pflicht und erforderlichen Reviews konfigurieren. Merge-/Squash-Berechtigungen und etwaige Bypass-Rechte prüfen. Squash-Merges müssen im Website-Repository erlaubt sein.

### Bilder

`content/media` ist die Medienablage des Website-Repositories. **Die separate Asset Library schreibt direkt nach `main`, unabhängig vom Editorial Workflow.** Für geprüfte Änderungen Medien innerhalb eines Inhaltsentwurfs hochladen. Bei geschütztem `main` ist die separate Asset Library für Benutzer ohne direkten Push-Zugriff schreibgeschützt.

Die HTML-Vorlage verwendet fest `content/media/hero.jpg`. Ein anderer Dateiname ändert das Hero-Bild nicht. Die Hero-Bildauswahl ist derzeit kein eigenes CMS-Feld, da sie in `index.html` und nicht in einer Inhaltsdatei liegt. Zum geprüften Austausch kann alternativ ein GitHub-Pull-Request verwendet werden.

`site_url` und `display_url` zeigen auf die GitHub-Pages-Website. Bei Wechsel auf eine eigene Domain die beiden URLs ändern. `public_folder: content/media` bleibt domainunabhängig: Der Website-Build löst diese CMS-Medienpfade relativ zur jeweiligen Seitentiefe auf.

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
