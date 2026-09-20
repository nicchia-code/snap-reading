# SnapReading

**SnapReading** è un'applicazione web mobile-first per la lettura veloce basata sulla tecnica **RSVP (Rapid Serial Visual Presentation)**, sviluppata in **Flutter** e compilata in **WebAssembly (WASM)** per offrire prestazioni native direttamente nel browser su GitHub Pages.

---

## Funzionalità Principali

- **Mirino RSVP con Optimal Recognition Point (ORP)**:
  - Le parole scorrono una alla volta in un punto focale fisso.
  - La lettera di riconoscimento ottimale (ORP) è evidenziata in rosso corallo e ancorata al centro del mirino, eliminando i movimenti saccadici degli occhi.
- **Smart Chunking (Lettura Foveale)**:
  - Raggruppamento automatico di coppie di parole brevi ($\le 11$ caratteri totali, es. *"in un"*, *"a tempo"*).
  - Lo sguardo si fissa nello spazio centrale tra le due parole, sfruttando l'elaborazione foveale parallela.
  - **Calibrazione Reale WPM**: la durata dei frame è calibrata matematicamente affinché il valore di WPM impostato corrisponda esattamente alle parole lette al minuto reale.
- **Pause Fisiologiche Intelligenti**:
  - Pacing dinamico che applica pause prolungate su virgole e punti e virgola ($1.5\times$) e su punti, esclamativi e fine frase ($2.0\times$).
- **Modalità Schermo Intero (Full Screen)**:
  - Lettura priva di qualsiasi distrazione o barra del browser, attivabile dalla libreria, dal reader, dal drawer laterale o con il tasto `F`.
- **Parser EPUB Diretto**:
  - Rileva e decompone automaticamente i file `.epub` posizionati nella cartella `assets/books/`.
  - Estrae metadati, capitoli e testo puro senza dipendenze native.
- **Interfaccia Mobile-First (Portrait & Landscape)**:
  - Pensata per smartphone con controlli touch essenziali e drawer laterale (swipe o tap) per statistiche, regolazione velocità (150–900 WPM), dimensione carattere e navigazione capitoli.
- **Persistenza Locale**:
  - Salva automaticamente capitolo, parola e preferenze nel browser (`localStorage` tramite `shared_preferences`).

---

## Controlli e Scorciatoie

| Azione | Mobile Touch | Desktop / Tastiera |
| :--- | :--- | :--- |
| **Play / Pausa** | Tap al centro dello schermo | `Spazio` |
| **Smart Chunking (On/Off)** | Selettore nel Drawer | `C` |
| **Schermo Intero** | Icona nell'AppBar / Drawer | `F` |
| **Salto indietro / avanti** | Pulsanti `-10` / `+10` parole | `Freccia Sinistra` / `Freccia Destra` |
| **Regola Velocità WPM** | Slider / tasti `+/-25` nel Drawer | `Freccia Su` / `Freccia Giù` |
| **Menu Controlli & Statistiche** | Swipe dal bordo destro / Icona menu | Icona menu in alto a destra |

---

## Come Aggiungere Nuovi Libri

È sufficiente inserire uno o più file `.epub` nella cartella:
```bash
assets/books/
```
All'avvio o premendo l'icona di ricarica nella Libreria, l'applicazione indicizzerà ed estrarrà automaticamente titoli, capitoli e contenuti.

---

## Sviluppo Locale e Test

### Prerequisiti
- [Flutter SDK](https://docs.flutter.dev/) (versione 3.22+ per supporto WASM)

### Comandi utili

```bash
# Dipendenze
flutter pub get

# Esecuzione locale
flutter run -d chrome
# Oppure per testare da smartphone sulla rete locale:
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

# Esecuzione test unitari
flutter test

# Analisi statica del codice
flutter analyze

# Compilazione WebAssembly locale
flutter build web --wasm --base-href /snap-reading/
```

---

## Deploy su GitHub Pages (WASM)

Il repository include un workflow GitHub Actions in [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) configurato per:
- Attivarsi automaticamente a ogni push sul branch `main`.
- Compilare l'app in WASM con `--base-href /snap-reading/`.
- Pubblicare il bundle su GitHub Pages.

Lo script [web/coi-serviceworker.js](web/coi-serviceworker.js) garantisce la compatibilità con Cross-Origin Isolation (COOP/COEP) anche sull'hosting gratuito di GitHub Pages.
