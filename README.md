# Einführung in Internet of Things IoT 

Dies ist das GitHub Repository für den modulübergreifende Kurs "Einführung in Internet of Things IoT" für Vertiefungsprofile Bachelor Geomatik.
Die Inhalte des Kurses sind in der [Kurswebseite](https://314a.github.io/5200_IoT) zu finden.


Github Page: https://314a.github.io/5200_IoT
Github Repository: https://github.com/314a/5200_IoT

Die Kurswebseite wird mit [Quarto](https://quarto.org/) erstellt mit zusätzlichen Anpassungen des Designs.


# Setup & Render
Dieses Quarto Repository wird lokal und nicht über GitHub Action gerendert und erfordert eine lokale Installation von [Quarto](https://quarto.org/docs/get-started/index.html). Die GitHub Pages werden über den Ordner `docs` bereitgestellt.

Aufbau der YAML Dateiein entspricht nicht dem Standard *Book* Format von Quarto. Das Standard Book Format ermöglicht keine einfache Auskoppelung von Kaptieln / Übungen, sondern rendert immer das gesamte Projekt. Über ein Standard Projekt mit mehreren Quarto Profilen ist es möglich ein Profil für die Kapitel *chapter* zu erstellen und ein Profil für das Gesamte Projekt *book*.

Struktur der YAML Dateien:

- *_quarto.yaml*: Einstellungen für das gesamte Projekt
- *_quarto_chapter.yaml*: Einstellungen für das Profil *chapter*, rendert die QMD Dateien in den Ordnern *chapters*.
- *_quarto_book.yaml*: Einstellungen für das Profil *book*, kopiert im Prerender über eine Batch-Datei die Ordner *chapters* und *slides* in den Ordner *docs* und rendert im Anschluss das gesamte Projekt.

Rendern des Projekts:

```bash
quarto render --profile chapter
quarto render --profile book
```

## Anzeigen der Lösungen
Die Option `solution:true` in den YAML Dateien aktiviert die Lösungen für die Übungen, default ist `solution:false`. Die Lösungen sind in den .Qmd Dateien als 

```markdown
::: {#exr-e01}
**Einführung**\
Wie werden die Lösungen für dieses Projekt aktiviert?
:::

::: {.content-hidden unless-meta="solution"}
::: {#sol-e01}
Lösung der @exr-e01. Die Lösungen werden über die Option `solution:true` in der YAML Datei aktiviert.
:::
:::
```	

