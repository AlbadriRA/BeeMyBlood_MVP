# HL7 Bridge & FHIR Demo

Ce projet permet de convertir des messages HL7 v2 en FHIR JSON et de les visualiser dans une interface web.

## Prérequis

- Node.js installé pour la partie front-end (`fhir-demo`).
- Java + IDE (IntelliJ ou autre) pour la partie HL7 Bridge.
- Postman ou tout autre outil pour envoyer des requêtes HTTP.

---

## Installation et lancement

### 1. Front-end FHIR Demo

1. Ouvrir le dossier `fhir-demo`.
2. Installer les dépendances :

```bash
npm install

```

3. Lancer le serveur de développement :

```bash
npm run dev


```

4. Ouvrir un navigateur et accéder à :

```bash
http://localhost:3000
```

### 2. HL7 Bridge

1. Ouvrir le projet HL7 Bridge dans un IDE comme IntelliJ ou lancer le projet en ligne de commande.
2. S’assurer que le projet se compile et se lance correctement.

### 3. Tester la conversion HL7 → FHIR

1. Ouvrir Postman.
2. Créer une requête POST vers :

```bash
http://localhost:8080/hl7/v2
```

3. Dans l’onglet Body, sélectionner raw et Text puis copier le contenu suivant :

```bash
MSH|^~\&|INLOG|LAB|HUG|HOSP|20250810||ORU^R01|MSG0001|P|2.5
PID|||HUG-1234^^^HUG^PI||Dupontt^Marie^^^^^L||19850315|F|||12 RUE DE L'HOPITAL^^GENEVE^^1205^CHE||(022)3720000
OBR|1||LAB12345|882-1^ABO and Rh group panel - Blood^LN|||20250809
OBX|1|CWE|883-9^ABO group^LN||LA21325-8^A^LN|||N|||F
OBX|2|CWE|10331-7^RhD^LN||LA6576-8^Positive^LN|||N|||F
```

4. Cliquer sur Send.

5. Le serveur renverra un JSON FHIR représentant le patient et ses observations, qui s’affichera ensuite sur l’interface web.

### Note : port 8080 déjà utilisé

Si le port 8080 est déjà occupé, vous pouvez le libérer en suivant ces étapes sous Windows (en administrateur) :

1. Identifier le PID du processus qui utilise le port :

```bash
netstat -aon | findstr :8080
```

2. Terminer le processus avec le PID obtenu :

```bash
taskkill /PID <votre_pid> /F
```
