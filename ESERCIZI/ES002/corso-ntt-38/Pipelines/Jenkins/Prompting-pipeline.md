Devi generare una pipeline jankins che preveda, in funzione di quanto hai progettato nel progetto corrente:

- Download da git dei sorgenti sulla macchina server di jenkis utile per l'esecuzione degli step: git clone https://gitlab.corso.local/gr38/corso-ntt-38.git
- Esecuzione unit test tramite maven
- Esecuzione analisi statica sorgenti su sonarqube tramite maven
- Generazione Artifatto jar tramite maven
- Esecuzione test cypress
- Generazione immagine tramite Dockerfile usando maven
- Deployment su kubernetes