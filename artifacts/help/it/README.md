# SnapReading - Guida Utente (Italiano)

SnapReading è un'applicazione web per la lettura rapida basata sulla tecnica RSVP (Rapid Serial Visual Presentation) con focalizzazione ORP (Optimal Recognition Point) in stile Spritz, compilata in WebAssembly (WASM).

## Funzionalità Principali

1. **Libreria di Libri EPUB (`assets/books/`)**:
   - L'applicazione rileva ed estrae automaticamente i libri e i capitoli presenti in `assets/books/`.
   - Mostra titolo, autore, numero di capitoli e stato di avanzamento per ciascun libro.

2. **Lettura RSVP con Punto Focale (ORP)**:
   - Le parole vengono mostrate una alla volta in un mirino fisso con guide orizzontali e mirino centrale.
   - La lettera di riconoscimento ottimale (ORP) è evidenziata in rosso/arancione e mantenuta sempre al centro per eliminare i movimenti saccadici degli occhi.
   - **Pause Intelligenti**: pause più lunghe per virgole/punti e virgola (1.5x) e punti/esclamativi/fine frase (2.0x).

3. **Interfaccia Mobile-First Ultra-Minimale**:
   - Ottimizzata per smartphone sia in orientamento **Portrait** che **Landscape**.
   - **Tap sullo schermo**: Avvia o mette in pausa la lettura.
   - **Scorciatoie da tastiera**:
     - `Spazio`: Play / Pausa.
     - `Freccia Sinistra / Destra`: Salto indietro o avanti di 10 parole.
     - `Freccia Su / Giù`: Incrementa o decrementa la velocità di 25 WPM.

4. **Pannello Laterale (Statistiche e Controlli)**:
   - Apribile con uno swipe laterale o toccando l'icona menu in alto a destra.
   - **Statistiche in tempo reale**: percentuale di lettura, parole lette/totali, tempo rimanente stimato in minuti.
   - **Regolazione Velocità (WPM)**: slider da 150 a 900 WPM e bottoni rapidi (-50, -25, +25, +50).
   - **Dimensione Carattere**: slider per regolare la dimensione del font da 24 a 56 px.
   - **Barra di avanzamento capitolo**: slider per spostarsi in qualsiasi punto del capitolo corrente.
   - **Elenco Capitoli**: navigazione diretta tra i capitoli.

5. **Salvataggio Automatico dei Progressi**:
   - La posizione di lettura (capitolo e parola) e le preferenze (WPM, dimensione font) vengono salvate automaticamente nella memoria locale del browser (`localStorage` via SharedPreferences).
